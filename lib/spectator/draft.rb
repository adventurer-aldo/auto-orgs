class Sunny

  BOT.command :prepare_draft do |event|
    channel = BOT.channel(1125132585882898462)

    channel.send_embed do |embed|
      embed.title = "Alvivor S3: Spirits & Souls — Draft Game"
      embed.description = "Make **4 choices:**\nYour Winner Pick -- who you bet will win the game\nPlus three other picks -- contenders who you think will make it far, far into the end\n\nYou will receive points based on the ranking of your picks. Your winner pick's ranking is worth double, so choose carefully!\n\n**The spectator with the least amount of points possible remaining at the end... wins the Draft Game.**"
      embed.color = '#CB00FF'
    end

    players = Player.where(season_id: Setting.last.season)

    winner_view = Discordrb::Webhooks::View.new
    winner_view.row { |row| row.string_select(custom_id: "DraftWinnerPick", options: players.map { |player| {label: player.name, value: player.id} }) }
    channel.send_message("**Winner Pick**", false, nil, nil, nil, nil, winner_view)
    
    first_view = Discordrb::Webhooks::View.new
    first_view.row { |row| row.string_select(custom_id: "DraftFirstPick", options: players.map { |player| {label: player.name, value: player.id} }) }
    channel.send_message("**Pick 1**", false, nil, nil, nil, nil, first_view)
    
    second_view = Discordrb::Webhooks::View.new
    second_view.row { |row| row.string_select(custom_id: "DraftSecondPick", options: players.map { |player| {label: player.name, value: player.id} }) }
    channel.send_message("**Pick 2**", false, nil, nil, nil, nil, second_view)
    
    third_view = Discordrb::Webhooks::View.new
    third_view.row { |row| row.string_select(custom_id: "DraftThirdPick", options: players.map { |player| {label: player.name, value: player.id} }) }
    channel.send_message("**Pick 3**", false, nil, nil, nil, nil, third_view)
  end

  BOT.string_select(custom_id: 'DraftWinnerPick') do |event|
    event.defer_update
    break if Council.where(season_id: Setting.last.season).exists?

    channel = BOT.channel(1125132585882898462)

    draft = SpectatorGame::Draft.find_or_create_by(user_id: event.user.id)

    new_pick = event.values.first.to_i

    player = Player.find_by(id: new_pick)

    picks = [draft.winner_pick, draft.pick_1, draft.pick_2, draft.pick_3]

    if picks.include? new_pick
      event.send_message(content: "Invalid choice! **#{player.name}** is already your #{['Winner Pick', 'Pick 1', 'Pick 2', 'Pick 3'][picks.index(new_pick)]}", ephemeral: true)
    else
      is_completed_draft = !draft.winner_pick.nil? && !draft.pick_1.nil? && !draft.pick_2.nil? && !draft.pick_3.nil?
      
      draft.update(winner_pick: new_pick)
      draft = draft.reload
      is_still_completed_draft = !draft.winner_pick.nil? && !draft.pick_1.nil? && !draft.pick_2.nil? && !draft.pick_3.nil?

      event.send_message(content: "**#{player.name}** is now your new **Winner Pick**!", ephemeral: true)

      if is_completed_draft != is_still_completed_draft
        channel.send_message("A new Draft has been completed, by #{event.user.mention}!")
        channel.send_file(Sunny.get_draft_image, filename: 'Draft.png')
      end
    end
  end

  BOT.string_select(custom_id: 'DraftFirstPick') do |event|
    event.defer_update
    break if Council.where(season_id: Setting.last.season).exists?

    channel = BOT.channel(1125132585882898462)

    draft = SpectatorGame::Draft.find_or_create_by(user_id: event.user.id)

    new_pick = event.values.first.to_i

    player = Player.find_by(id: new_pick)

    picks = [draft.winner_pick, draft.pick_1, draft.pick_2, draft.pick_3]

    if picks.include? new_pick
      event.send_message(content: "Invalid choice! **#{player.name}** is already your #{['Winner Pick', 'Pick 1', 'Pick 2', 'Pick 3'][picks.index(new_pick)]}", ephemeral: true)
    else
      is_completed_draft = !draft.winner_pick.nil? && !draft.pick_1.nil? && !draft.pick_2.nil? && !draft.pick_3.nil?
      
      draft.update(pick_1: new_pick)
      draft = draft.reload
      is_still_completed_draft = !draft.winner_pick.nil? && !draft.pick_1.nil? && !draft.pick_2.nil? && !draft.pick_3.nil?

      event.send_message(content: "**#{player.name}** is now your new **Pick 1**!", ephemeral: true)

      if is_completed_draft != is_still_completed_draft
        channel.send_message("A new Draft has been completed, by #{event.user.mention}!")
        channel.send_file(Sunny.get_draft_image, filename: 'Draft.png')
      end
    end
  end

  BOT.string_select(custom_id: 'DraftSecondPick') do |event|
    event.defer_update
    break if Council.where(season_id: Setting.last.season).exists?

    channel = BOT.channel(1125132585882898462)

    draft = SpectatorGame::Draft.find_or_create_by(user_id: event.user.id)

    new_pick = event.values.first.to_i

    player = Player.find_by(id: new_pick)

    picks = [draft.winner_pick, draft.pick_1, draft.pick_2, draft.pick_3]

    if picks.include? new_pick
      event.send_message(content: "Invalid choice! **#{player.name}** is already your #{['Winner Pick', 'Pick 1', 'Pick 2', 'Pick 3'][picks.index(new_pick)]}", ephemeral: true)
    else
      is_completed_draft = !draft.winner_pick.nil? && !draft.pick_1.nil? && !draft.pick_2.nil? && !draft.pick_3.nil?
      
      draft.update(pick_2: new_pick)
      draft = draft.reload
      is_still_completed_draft = !draft.winner_pick.nil? && !draft.pick_1.nil? && !draft.pick_2.nil? && !draft.pick_3.nil?

      event.send_message(content: "**#{player.name}** is now your new **Pick 2**!", ephemeral: true)

      if is_completed_draft != is_still_completed_draft
        channel.send_message("A new Draft has been completed, by #{event.user.mention}!")
        channel.send_file(Sunny.get_draft_image, filename: 'Draft.png')
      end
    end
  end

  BOT.string_select(custom_id: 'DraftThirdPick') do |event|
    event.defer_update
    break if Council.where(season_id: Setting.last.season).exists?

    channel = BOT.channel(1125132585882898462)

    draft = SpectatorGame::Draft.find_or_create_by(user_id: event.user.id)

    new_pick = event.values.first.to_i

    player = Player.find_by(id: new_pick)

    picks = [draft.winner_pick, draft.pick_1, draft.pick_2, draft.pick_3]

    if picks.include? new_pick
      event.send_message(content: "Invalid choice! **#{player.name}** is already your #{['Winner Pick', 'Pick 1', 'Pick 2', 'Pick 3'][picks.index(new_pick)]}", ephemeral: true)
    else
      is_completed_draft = !draft.winner_pick.nil? && !draft.pick_1.nil? && !draft.pick_2.nil? && !draft.pick_3.nil?
      
      draft.update(pick_3: new_pick)
      draft = draft.reload
      is_still_completed_draft = !draft.winner_pick.nil? && !draft.pick_1.nil? && !draft.pick_2.nil? && !draft.pick_3.nil?

      event.send_message(content: "**#{player.name}** is now your new **Pick 3**!", ephemeral: true)

      if is_completed_draft != is_still_completed_draft
        channel.send_message("A new Draft has been completed, by #{event.user.mention}!")
        channel.send_file(Sunny.get_draft_image, filename: 'Draft.png')
      end
    end
  end
  
end