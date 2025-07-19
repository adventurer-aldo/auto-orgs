class Sunny

  BOT.command :prepare_stuff do |event|
    Player.where(status: ALIVE).each { |player| player.individuals.create(start_time: Time.now.to_i, challenge_id: 0) if player.individuals.size.zero? }
  end

  BOT.command :trivia do |event|
    return unless event.user.id.player?

    player = Player.find_by(season: Setting.last.season, user_id: event.user.id)
    individual = player.individuals.first

    return unless individual.stage == 0
    individual.update(stage: 1)
    event.respond("**Who's the first castaway eliminated from the season?**")
  end

  BOT.command :chess do |event|
    return unless event.user.id.player?

    player = Player.find_by(season: Setting.last.season, user_id: event.user.id)
    individual = player.individuals.first

    return unless individual.stage == 1
    individual.update(stage: 2)
    event.respond("**Who's the second castaway eliminated by the Hot Potato?**")
  end

  BOT.command :oscar do |event|
    return unless event.user.id.player?

    player = Player.find_by(season: Setting.last.season, user_id: event.user.id)
    individual = player.individuals.first

    return unless individual.stage == 2
    individual.update(stage: 3)
    event.respond("**Which tribe took the yellow color during the first tribe swap?**")
  end

  BOT.command :panthera do |event|
    return unless event.user.id.player?

    player = Player.find_by(season: Setting.last.season, user_id: event.user.id)
    individual = player.individuals.first

    return unless individual.stage == 3
    individual.update(stage: 4)
    event.respond("**Which tribe won the Battleship challenge?**")
  end

  BOT.command :canis do |event|
    return unless event.user.id.player?

    player = Player.find_by(season: Setting.last.season, user_id: event.user.id)
    individual = player.individuals.first

    return unless individual.stage == 4
    individual.update(stage: 5)
    event.channel.send_file(URI.parse('https://seaworld.org/-/media/migrated-media/seaworld-dotorg/audio-files/sound-library/elephant.wav?version=1_201811134825').open, filename: 'sound.wav')
    event.respond("**Which tribe does this animal belong to?**")
  end

  BOT.command :testtesttest do |event|
    event.channel.send_file(URI.parse('https://seaworld.org/-/media/migrated-media/seaworld-dotorg/audio-files/sound-library/elephant.wav?version=1_201811134825').open, filename: 'sound.wav')
    event.respond("**Which tribe does this animal belong to?**")
  end

  BOT.command :elephas do |event|
    return unless event.user.id.player?

    player = Player.find_by(season: Setting.last.season, user_id: event.user.id)
    individual = player.individuals.first

    return unless individual.stage == 5
    individual.update(stage: 6)
    event.respond("**Which castaways occupy the spot of 12th in this season? Separate them with an underscore.**")
  end

  BOT.command(:cameron_schulz, { aliases: [:schulz_cameron] }) do |event|
    event.respond("You're a host!") if event.user.id.host?
    return unless event.user.id.player?

    player = Player.find_by(season: Setting.last.season, user_id: event.user.id)
    individual = player.individuals.first

    return unless individual.stage == 6
    individual.update(stage: 7)
    event.respond("**Which tribe participated in most Joint Tribal Councils?**")
  end

  BOT.command :falco do |event|
    return unless event.user.id.player?

    player = Player.find_by(season: Setting.last.season, user_id: event.user.id)
    individual = player.individuals.first

    return unless individual.stage == 7
    individual.update(stage: 8)
    event.respond("**Who was the first member of the jury?**")
  end

  BOT.command :cameron do |event|
    return unless event.user.id.player?

    player = Player.find_by(season: Setting.last.season, user_id: event.user.id)
    individual = player.individuals.first

    return unless individual.stage == 8
    individual.update(stage: 9)
    event.respond("**Which tribe never participated in a Tribal Council?**")
  end

  BOT.command :serpentes do |event|
    return unless event.user.id.player?

    player = Player.find_by(season: Setting.last.season, user_id: event.user.id)
    individual = player.individuals.first

    return unless individual.stage == 9
    individual.update(stage: 10)
    event.respond("**Which alumni castaway was eliminated in the pre-jury?**")
  end

  BOT.command :corrin do |event|
    return unless event.user.id.player?

    player = Player.find_by(season: Setting.last.season, user_id: event.user.id)
    individual = player.individuals.first

    return unless individual.stage == 10
    individual.update(stage: 11)
    event.respond("**Who's the castaway eliminated before the merge tribe?**")
  end

  BOT.command :schulz do |event|
    return unless event.user.id.player?

    player = Player.find_by(season: Setting.last.season, user_id: event.user.id)
    individual = player.individuals.first

    return unless individual.stage == 11
    individual.update(stage: 12)
    event.respond("**What's the name of this season?**")
  end

  BOT.command :animals do |event|
    return unless event.user.id.player?

    player = Player.find_by(season: Setting.last.season, user_id: event.user.id)
    individual = player.individuals.first

    return unless individual.stage == 12
    end_time = Time.now.to_i
    individual.update(stage: 13, end_time: end_time)
    event.respond("You finished the fire-making challenge with... **#{end_time - individual.start_time} seconds!**")
  end

end