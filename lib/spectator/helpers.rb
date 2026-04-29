class Sunny
  def self.current_episode
    Episode.where(season_id: Setting.season_id).order(:number, :id).last ||
      Episode.create(season_id: Setting.season_id, number: 1)
  end

  def self.spectator_games_open?
    active_councils.empty?
  end

  def self.channel_from_setting(setting_name)
    channel_id = Setting.public_send(setting_name)
    return nil if channel_id.zero?

    BOT.channel(channel_id)
  rescue StandardError => e
    raise unless e.class.name.match?(/Unknown.*Channel|No.*Permission|Not.*Found/) ||
                 e.message.match?(/Unknown Channel|Missing Access|Missing Permissions/)

    nil
  end

  def self.spectator_channel_missing_message(game_name, setting_name)
    "I couldn't find the #{game_name} channel. Set `Setting.#{setting_name}` to a valid channel ID first."
  end

  def self.respond_missing_spectator_channel(event, game_name, setting_name)
    message = spectator_channel_missing_message(game_name, setting_name)

    if event.respond_to?(:send_message)
      event.send_message(content: message, ephemeral: true)
    else
      event.respond(message)
    end
  end

  def self.bootlist_open?
    spectator_games_open? && !Council.where(season_id: Setting.season_id).exists?
  end

  def self.model_column(model, candidates)
    candidates.find { |column| model.column_names.include?(column.to_s) }
  end

  def self.set_model_value(record, candidates, value)
    column = model_column(record.class, candidates)
    return false unless column

    record.update(column => value)
  end

  def self.spectator_active_scope(model)
    scope = model.where(season_id: Setting.season_id)
    model.column_names.include?('status') ? scope.where.not(status: 0) : scope
  end

  def self.mark_spectator_game_lost(record)
    record.update(status: 0) if record.class.column_names.include?('status')
  end

  def self.unique_lowest(records)
    grouped = records.group_by { |record| record.score || 0 }
    return nil if grouped.empty?

    winners = grouped[grouped.keys.min]
    winners.one? ? winners.first : nil
  end

  def self.spectator_game_winner_name(user_id)
    user = BOT.user(user_id)
    user.on(Setting.server_id)&.display_name || user.username
  rescue StandardError
    'Deleted User'
  end

  def self.announce_spectator_game_winner(channel, user_id, game_name)
    channel&.send_message("**#{spectator_game_winner_name(user_id)} cannot be beaten by anyone else... #{spectator_game_winner_name(user_id)} has won the #{game_name}!**")
  end

  def self.completed_drafts
    SpectatorGame::Draft.where(season_id: Setting.season_id).select { |draft| completed_draft?(draft) }
  end

  def self.close_draft_game_if_won
    return unless Setting.spectator_draft_is_ongoing == 1
    return unless Player.where(season_id: Setting.season_id, status: ALIVE).size <= 1

    winner = unique_lowest(completed_drafts)
    return unless winner

    Setting.spectator_draft_is_ongoing = 0
    announce_spectator_game_winner(draft_channel, winner.user_id, 'Draft Game')
  end

  def self.close_elimination_game_if_won
    return unless Setting.spectator_elimination_is_ongoing == 1

    active = spectator_active_scope(SpectatorGame::Elimination).to_a
    return unless active.one?

    Setting.spectator_elimination_is_ongoing = 0
    announce_spectator_game_winner(elimination_channel, active.first.user_id, 'Elimination Game')
  end

  def self.close_bootlist_game_if_won
    return unless Setting.spectator_bootlist_is_ongoing == 1
    return unless Player.where(season_id: Setting.season_id, status: ALIVE).size <= 1

    winner = unique_lowest(SpectatorGame::Bootlist.where(season_id: Setting.season_id).to_a)
    return unless winner

    Setting.spectator_bootlist_is_ongoing = 0
    announce_spectator_game_winner(bootlist_channel, winner.user_id, 'Bootlist Game')
  end

  def self.update_spectator_games_after_elimination
    draft_channel&.send_file(get_draft_image, filename: 'Draft.png') if Setting.spectator_draft_is_ongoing == 1
    elimination_channel&.send_file(get_eliminator_image, filename: 'Eliminator.png') if Setting.spectator_elimination_is_ongoing == 1
    bootlist_channel&.send_file(get_bootlist_image, filename: 'Bootlist.png') if Setting.spectator_bootlist_is_ongoing == 1

    close_draft_game_if_won
    close_elimination_game_if_won
    close_bootlist_game_if_won
  end

  def self.spectator_game_prompt_view
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.button(custom_id: 'spectator_start_draft', label: 'Start Draft', style: :primary) if Setting.spectator_draft_is_ongoing.zero?
      row.button(custom_id: 'spectator_start_elimination', label: 'Start Elimination', style: :primary) if Setting.spectator_elimination_is_ongoing.zero?
      row.button(custom_id: 'spectator_start_bootlist', label: 'Start Bootlist', style: :primary) if Setting.spectator_bootlist_is_ongoing.zero? && bootlist_open?
    end
    view
  end

  def self.prompt_spectator_games(channel)
    draft_closed = Setting.spectator_draft_is_ongoing.zero?
    elimination_closed = Setting.spectator_elimination_is_ongoing.zero?
    bootlist_closed = Setting.spectator_bootlist_is_ongoing.zero? && bootlist_open?
    return unless draft_closed || elimination_closed || bootlist_closed

    channel.send_message('Spectator games are now available. Start any that should open for this season?', false, nil, nil, nil, nil, spectator_game_prompt_view)
  end

  def self.spectator_user?(user)
    player = Player.find_by(user_id: user.id, season_id: Setting.season_id)
    player.nil?
  end
end
