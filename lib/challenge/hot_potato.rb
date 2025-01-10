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
    mapped_players = players.map(&:name)
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
    players = Participant.where(status: 1).map { |player| Player.find_by(id: player.player_id) }
    passer = Player.where(status: ALIVE).first

    target = args.join('').downcase
    mapped_players = players.map(&:name)
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

    event.respond("More than a single seedling matches that...") if matches.size > 1
    break if matches.size > 1

    event.respond("No single seedling matches that...") if matches.size.zero?
    break if matches.size.zero?

    event.respond("That's you...") if matches.first.user_id == event.user.id
    break if matches.first.user_id == event.user.id

    Potato.all.first.update(player_id: matches.first.id)
    event.respond("The :potato: **Hot Potato** was passed to #{BOT.user(matches.first.user_id).mention}!")
  end
end