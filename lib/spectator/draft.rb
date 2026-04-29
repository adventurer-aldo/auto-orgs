class Sunny
  def self.draft_channel
    BOT.channel(Setting.spectator_draft_channel_id)
  end

  def self.completed_draft?(draft)
    !draft.winner_pick.nil? && !draft.pick_1.nil? && !draft.pick_2.nil? && !draft.pick_3.nil?
  end

  def self.draft_pick_options(players)
    players.first(25).map { |player| { label: player.name, value: player.id.to_s } }
  end

  def self.handle_draft_pick(event, pick_column, pick_label)
    event.defer_update
    return if Council.where(season_id: Setting.season_id).exists?

    draft = SpectatorGame::Draft.find_or_create_by(user_id: event.user.id, season_id: Setting.season_id)
    new_pick = event.values.first.to_i
    player = Player.find_by(id: new_pick, season_id: Setting.season_id)
    return unless player

    picks = [draft.winner_pick, draft.pick_1, draft.pick_2, draft.pick_3]

    if picks.include? new_pick
      event.send_message(content: "Invalid choice! **#{player.name}** is already your #{['Winner Pick', 'Pick 1', 'Pick 2', 'Pick 3'][picks.index(new_pick)]}", ephemeral: true)
    else
      was_completed = completed_draft?(draft)

      draft.update(pick_column => new_pick)
      draft = draft.reload
      is_completed = completed_draft?(draft)

      event.send_message(content: "**#{player.name}** is now your new **#{pick_label}**!", ephemeral: true)

      if was_completed != is_completed
        draft_channel.send_message("A new Draft has been completed, by #{event.user.mention}!")
        draft_channel.send_file(get_draft_image, filename: 'Draft.png')
      end
    end
  end

  BOT.command :prepare_draft do |event|
    channel = draft_channel

    channel.send_embed do |embed|
      embed.title = "#{season_title} — Draft Game"
      embed.description = "Make **4 choices:**\nYour Winner Pick -- who you bet will win the game\nPlus three other picks -- contenders who you think will make it far, far into the end\n\nYou will receive points based on the ranking of your picks. Your winner pick's ranking is worth double, so choose carefully!\n\n**The spectator with the least amount of points possible remaining at the end... wins the Draft Game.**"
      embed.color = '#CB00FF'
    end

    players = Player.where(season_id: Setting.season_id)

    winner_view = Discordrb::Webhooks::View.new
    winner_view.row { |row| row.string_select(custom_id: "DraftWinnerPick", options: draft_pick_options(players)) }
    channel.send_message("**Winner Pick**", false, nil, nil, nil, nil, winner_view)
    
    first_view = Discordrb::Webhooks::View.new
    first_view.row { |row| row.string_select(custom_id: "DraftFirstPick", options: draft_pick_options(players)) }
    channel.send_message("**Pick 1**", false, nil, nil, nil, nil, first_view)
    
    second_view = Discordrb::Webhooks::View.new
    second_view.row { |row| row.string_select(custom_id: "DraftSecondPick", options: draft_pick_options(players)) }
    channel.send_message("**Pick 2**", false, nil, nil, nil, nil, second_view)
    
    third_view = Discordrb::Webhooks::View.new
    third_view.row { |row| row.string_select(custom_id: "DraftThirdPick", options: draft_pick_options(players)) }
    channel.send_message("**Pick 3**", false, nil, nil, nil, nil, third_view)
  end

  BOT.string_select(custom_id: 'DraftWinnerPick') do |event|
    handle_draft_pick(event, :winner_pick, 'Winner Pick')
  end

  BOT.string_select(custom_id: 'DraftFirstPick') do |event|
    handle_draft_pick(event, :pick_1, 'Pick 1')
  end

  BOT.string_select(custom_id: 'DraftSecondPick') do |event|
    handle_draft_pick(event, :pick_2, 'Pick 2')
  end

  BOT.string_select(custom_id: 'DraftThirdPick') do |event|
    handle_draft_pick(event, :pick_3, 'Pick 3')
  end
  
end
