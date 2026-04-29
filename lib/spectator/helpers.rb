class Sunny
  def self.current_episode
    Episode.where(season_id: Setting.season_id).order(:number, :id).last ||
      Episode.create(season_id: Setting.season_id, number: 1)
  end

  def self.spectator_games_open?
    active_councils.empty?
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
