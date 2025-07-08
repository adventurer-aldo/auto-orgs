class Sunny

  BOT.command :setup_who do |event|
    Individual.destroy_all
    event.respond("All individuals have been destroyed.")
  end

  BOT.command :guess_who do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break unless player.individuals.empty?

    individual = Individual.create(player_id: player.id, stage: 0, start_time: Time.now.to_i)
    event.respond("The timer has begun! Guess who the following animal is and answer with a command!")
    file = URI.parse("https://seaworld.org/-/media/migrated-media/seaworld-dotorg/audio-files/sound-library/domestic_cat.wav?version=1_201811134819").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.ogg')
  end

  BOT.command :cat do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 0
    individual.update(stage: 1)
    event.respond("Correct! Next up...")
    file = URI.parse("https://seaworld.org/-/media/migrated-media/seaworld-dotorg/audio-files/sound-library/wolf.wav?version=1_201811134820").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.ogg')
  end

  BOT.command :wolf do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 1
    individual.update(stage: 2)
    event.respond("Correct! Next up...")
    file = URI.parse("https://seaworld.org/-/media/migrated-media/seaworld-dotorg/audio-files/sound-library/dogbark.wav?version=1_201811134824").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.ogg')
  end

  BOT.command :dog do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 2
    individual.update(stage: 3)
    event.respond("Correct! Next up...")
    file = URI.parse("https://www.animal-sounds.org/jungle/Elephant%20trumpeting%20animals129.wav").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.wav')
  end

  BOT.command :elephant do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 3
    individual.update(stage: 4)
    event.respond("Correct! Next up...")
    file = URI.parse("https://www.animal-sounds.org/jungle/Monkey%20chatter%20animals059.wav").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.wav')
  end

  BOT.command :monkey do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 4
    individual.update(stage: 5)
    event.respond("Correct! Next up...")
    file = URI.parse("https://seaworld.org/-/media/migrated-media/seaworld-dotorg/audio-files/sound-library/frog.wav?version=1_201811134824").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.wav')
  end

  BOT.command :frog do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 5
    individual.update(stage: 6)
    event.respond("Correct! Next up...")
    file = URI.parse("https://www.animal-sounds.org/farm/Cow%20animals055.wav").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.wav')
  end

  BOT.command :cow do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 6
    individual.update(stage: 7)
    event.respond("Correct! Next up...")
    file = URI.parse("https://seaworld.org/-/media/migrated-media/seaworld-dotorg/audio-files/sound-library/clydesdale.mp3?version=1_201811130506").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.mp3')
  end

  BOT.command :bull do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 6
    individual.update(stage: 7)
    event.respond("Correct! Next up...")
    file = URI.parse("https://seaworld.org/-/media/migrated-media/seaworld-dotorg/audio-files/sound-library/clydesdale.mp3?version=1_201811130506").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.mp3')
  end

  BOT.command :horse do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 7
    individual.update(stage: 8)
    event.respond("Correct! Next up...")
    file = URI.parse("https://seaworld.org/-/media/migrated-media/seaworld-dotorg/audio-files/sound-library/cougar.mp3?version=1_201811134819").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.mp3')
  end

  BOT.command :panther do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 8
    individual.update(stage: 9)
    event.respond("Correct! Next up...")
    file = URI.parse("https://freeanimalsounds.org/wp-content/uploads/2017/08/mosquito.mp3").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.mp3')
  end

  BOT.command :mosquito do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 9
    individual.update(stage: 10)
    event.respond("Correct! Next up...")
    file = URI.parse("https://freeanimalsounds.org/wp-content/uploads/2017/07/rattlesnake.mp3").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.mp3')
  end

  BOT.command :fly do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 9
    individual.update(stage: 10)
    event.respond("Correct! Next up...")
    file = URI.parse("https://freeanimalsounds.org/wp-content/uploads/2017/07/rattlesnake.mp3").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.mp3')
  end

  BOT.command :snake do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 10
    individual.update(stage: 11)
    event.respond("Correct! Next up... Respond with the plural of this one.")
    file = URI.parse("https://freeanimalsounds.org/wp-content/uploads/2017/07/wolf.mp3").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.mp3')
  end

  BOT.command :rattlesnake do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 10
    individual.update(stage: 11)
    event.respond("Correct! Next up... Respond with the plural of this one.")
    file = URI.parse("https://freeanimalsounds.org/wp-content/uploads/2017/07/wolf.mp3").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.mp3')
  end

  BOT.command :wolves do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 11
    individual.update(stage: 12)
    event.respond("Correct! Next up...")
    file = URI.parse("https://seaworld.org/-/media/migrated-media/seaworld-dotorg/audio-files/sound-library/falcon.wav?version=1_201811134818").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.wav')
  end

  BOT.command :falcon do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 12
    individual.update(stage: 13)
    event.respond("Correct! Next up...")
    file = URI.parse("https://freeanimalsounds.org/wp-content/uploads/2017/07/schafe.mp3").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.mp3')
  end

  BOT.command :sheep do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 13
    individual.update(stage: 14)
    event.respond("Correct! Next up...")
    file = URI.parse("https://freeanimalsounds.org/wp-content/uploads/2017/07/Ente_quackt.mp3").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.mp3')
  end

  BOT.command :duck do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 14
    individual.update(stage: 15)
    event.respond("Correct! Next up...")
    file = URI.parse("https://cdn.discordapp.com/attachments/1378044547287879731/1391834767002959872/ringa.ogg?ex=686d56a3&is=686c0523&hm=da0373185e3759c810de9a34efb5370647ab6e799765e7b83b666acd6f5ef6b1&").open
    BOT.send_file(event.channel, file, filename: 'mystery_animal.wav')
  end

  BOT.command :human do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.submissions
    break if player.individuals.empty?

    individual = player.individuals.first

    break unless individual.stage == 15
    individual.update(stage: 16)
    end_time = Time.now.to_i
    individual.update(end_time: end_time)
    event.respond("Correct! Your final time is... **#{end_time - individual.start_time} seconds!**")
  end
end
