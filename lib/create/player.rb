class Sunny
  def self.player_select_view(user_id)
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.user_select(custom_id: "players_select:#{user_id}", placeholder: 'Choose new castaways', min_values: 1, max_values: 25)
    end
    view
  end

  def self.register_players(cast, server)
    created = []
    cast.each do |person|
      player = Player.create(user_id: person.id, name: person.display_name, season_id: Setting.season_id,
      confessional: server.create_channel(
          "#{person.display_name}-confessional",
          parent: Setting.confessionals_category_id,
          topic: "#{person.display_name}'s Confessional. This is where you'll talk to the spectators about your game!",
          permission_overwrites: [Discordrb::Overwrite.new(person.id, type: 'member', allow: 3072),
          Sunny.true_spectate, Sunny.deny_every_spectate]).id,
      submissions: server.create_channel("#{person.display_name}-submissions",
          parent: Setting.confessionals_category_id,
          topic: 'Your Submissions channel. Submit challenge scores, check your inventory and play your items!',
          permission_overwrites: [Discordrb::Overwrite.new(person.id, type: 'member', allow: 3072),
          Sunny.deny_every_spectate]).id)

      person.on(server).add_role(Setting.castaway_role_id)
      person.on(server).remove_role(Setting.spectator_role_id)
      person.on(server).remove_role(Setting.trusted_spectator_role_id)

      BOT.channel(player.confessional).sort_after(BOT.channel(Setting.playing_splitter_channel_id))
      BOT.channel(player.submissions).sort_after(BOT.channel(player.confessional))
      BOT.send_message(player.confessional, "**Welcome to your confessional, <@#{person.id}>**\nThis is where you'll be talking about your game and the spectators will get a peek at your current mindset!")
      BOT.send_message(player.submissions, "**Welcome to your submissions channel!**\nHere you'll be putting your challenge scores, play, trade, receive items and submit your votes.\n\nTo start things off, check your inventory with `!help`!")
      created << player.name
    end

    Setting.season.update(start_time: Time.now)
    InServerStats.enqueue(job_options: {run_at: Time.now})
    created
  end

  BOT.command :players, description: 'Registers the user as a new player in the current season.' do |event|
    break unless event.user.id.host?

    cast = if event.message.role_mentions.size.positive?
             event.message.role_mentions.first.members
           else
             event.message.mentions.map { |user| user.on(event.server) }
           end

    unless cast.size.positive?
      event.channel.send_message('Choose new castaways.', false, nil, nil, nil, nil, player_select_view(event.user.id))
      break
    end

    created = register_players(cast, event.server)
    prompt_spectator_games(event.channel)
    return "New entries in Season #{Setting.season_id}'s cast:\n#{created.join("\n")}"
  end

  BOT.user_select(custom_id: /\Aplayers_select:/) do |event|
    user_id = event.custom_id.split(':', 2).last.to_i
    if user_id != event.user.id
      event.respond(content: 'Only the host who opened this menu can use it.', ephemeral: true)
      break
    end

    created = register_players(event.values.map { |user| user.on(event.server) }, event.server)
    event.update_message(content: "New entries in Season #{Setting.season_id}'s cast:\n#{created.join("\n")}", components: nil)
    prompt_spectator_games(event.channel)
  end

  BOT.button(custom_id: 'spectator_start_draft') do |event|
    break unless event.user.id.host?

    event.defer_update
    prepare_draft_game(draft_channel)
  end

  BOT.button(custom_id: 'spectator_start_elimination') do |event|
    break unless event.user.id.host?

    event.defer_update
    prepare_elimination_game
  end

  BOT.button(custom_id: 'spectator_start_bootlist') do |event|
    break unless event.user.id.host?

    event.defer_update
    prepare_bootlist_game(event)
  end
end
