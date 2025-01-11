class Sunny
  BOT.command :hot_potato do |event|
    break unless event.user.id.host?

    break unless event.channel.id == 1327288820529627146

    event.respond(":potato: **Hot Potato** has begun!\nAfter a not-so-random amount of time, the Potato will explode and take down the player holding it.")
    event.channel.start_typing
    sleep(2)
    event.respond("The seedling, selected at random, to hold the :potato: :potato: **Hot Potato** first is...")

    players = Player.where(status: ALIVE)
    players.each do |player|
      Participant.create(player_id: player.id)
    end
    target = players.sample()
    event.respond("#{BOT.user(target.user_id).mention()}!\nPass the potato with `!pass (TARGET'S NAME)` before it blows up!")
    Potato.all.first.update(player_id: target.id)
  end

  BOT.command :pass do |event, *args|
    break unless event.user.id.player?

    break unless event.channel.id == 1327032753463496855

    players = Participant.where(status: 1).map { |player| Player.find_by(id: player.player_id) }
    passer = Player.find_by(user_id: event.user.id, status: ALIVE)

    target = args.join('').downcase
    mapped_players = players.map(&:name).map(&:downcase)
    matches = []
    mapped_players.each_with_index do |player_name, index|
      if player_name.include?(target)
        matches << players[index]
      end
    end

    mention_matches = []
    if event.message.mentions.size.positive?
      ids = event.message.mentions.map { |user| user.id }
      ids.each do |id|
        if Player.where(status: ALIVE, user_id: id).exists?
          mention_matches << Player.find_by(user_id: id, status: ALIVE)
        end
      end
    end

    event.respond("Several seedlings were mentioned...") if mention_matches.size > 1
    break if mention_matches.size > 1

    matches = mention_matches if mention_matches.size == 1

    break unless Potato.all.first.player_id == passer.id

    event.respond("More than a single seedling matches that...") if matches.size > 1
    break if matches.size > 1

    event.respond("No single seedling matches that...") if matches.size.zero?
    break if matches.size.zero?

    event.respond("That's you...") if matches.first.user_id == event.user.id
    break if matches.first.user_id == event.user.id

    Potato.all.first.update(player_id: matches.first.id)
    event.respond("The :potato: **Hot Potato** was passed to #{BOT.user(matches.first.user_id).mention}!")
  end

  BOT.command :explode do |event, *args|
    break unless event.user.id.host?

    channel = BOT.channel(1327032753463496855)
    channel.send_message("It's getting... **HOT**!\n10...")
    channel.start_typing
    sleep(3)
    channel.send_message('9...')
    channel.start_typing
    sleep(3)
    channel.send_message('8...')
    channel.start_typing
    sleep(3)
    channel.send_message('7...')
    channel.start_typing
    sleep(3)
    channel.send_message('6...')
    channel.start_typing
    sleep(3)
    channel.send_message('5...')
    channel.start_typing
    sleep(3)
    channel.send_message('4...')
    channel.start_typing
    sleep(3)
    channel.send_message('3...')
    channel.start_typing
    sleep(3)
    channel.send_message('2...')
    channel.start_typing
    sleep(3)
    channel.send_message('1...')
    channel.start_typing
    sleep(3)
    unlucky = Player.find_by(id: Potato.all.last.player_id)
    channel.send_message(":boom: **KABOOM!! The Hot Potato blew up in #{unlucky.name}'s face!!**")
    Participant.where(player_id: unlucky.id).update(status: 0)
    sleep(2)
    participants = Participant.where(status: 1)

    player = Player.find_by(id: participants.map(&:player_id).sample)
    if participants.size < 2
      channel.start_typing
      sleep(2)
      channel.send_message("There's no more :potato: **Hot Potatoes** remaining!")
    else
      Potato.all.last.update(player_id: player.id)
      channel.send_message("A new :potato: **Hot Potato** appeared and dropped on #{BOT.user(player.user_id).mention}'s hands!\nPass the potato with `!pass (TARGET'S NAME)` before it blows up!")
      BOT.user(unlucky.user_id).on(event.server.id).add_role(1327318368507789465)
    end
    
    list = participants.map { |participant| Player.find_by(id: participant.player_id).name }.join("\n")
    channel.send_embed do |embed|
      embed.title = "Seedlings remaining:"
      embed.description = list
      embed.color = event.server.role(Tribe.all.last.role_id).color
    end
    if participants.size < 2
      channel.start_typing
      sleep(2)
      channel.send_message("As the sole remaining seedling... **#{player.name} wins the very first INDIVIDUAL IMMUNITY CHALLENGE!!")
    end
  end
end