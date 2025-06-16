class Sunny
  favorites = { 17 => {
    "Etho" => ["cat", "cats", "feline", "felines", "cerberus"],
    "Schulz" => ["dragon", "dragons", "drake", "drakes", "wyrm", "wyrms"],
    "Hoff" => ["bongo", "bongos", "bongo antelope", "bongo antelopes"],
    "Chess" => ["furret", "furrets", "ferret", "ferrets", "polecat", "polecats"],
    "Alex" => ["dog", "dogs", "canine", "canines", "puppy", "puppies"],
    "Dani" => ["whale shark", "whale sharks", "rhincodon typus"]
    },
    16 => {
    "Dixastro" => ["eagle", "eagles", "raptor", "raptors", 'bird', 'birds'],
    "Corrin" => ["seal", "seals", "pinniped", "pinnipeds"],
    "Hayden" => ["raccoon", "raccoons", "trash panda", "trash pandas"],
    "Oscar" => ["sloth", "sloths"],
    "RedPanda" => ["red panda", "red pandas", "lesser panda", "lesser pandas", "firefox", 'redpanda', 'redpandas'],
    "Jack" => ["axolotl", "axolotls", "mexican walking fish"]
    },
    15 => {
    "Cameron" => ["cat", "cats", "feline", "felines"],
    "Duke" => ["dog", "dogs", "canine", "canines", "puppy", "puppies"],
    "London" => ["ferret", "ferrets", "polecat", "polecats", "furret", "furrets"],
    "Tbarnez" => ["koala", "koalas", "koala bear", "koala bears"],
    "Josh" => ["octopus", "octopi", "octopuses", "cephalopod", "cephalopods"],
    "Lynn" => ["cat", "cats", "feline", "felines"]
    }
  }

  BOT.message(in: Setting.last.tribes.map { |tribe_id| Tribe.find_by(id: tribe_id).cchannel_id}) do |event|
    break #unless event.user.id.player?
    player = Player.find_by(user_id: event.user.id)

    break unless player.tribe.challenges.size.positive?

    challenge = player.tribe.challenges.first

    break if challenge.start_time == nil
    
    break if challenge.stage >= 6

    break if event.message.content[0] == '!'


    if favorites[player.tribe.id][favorites[player.tribe.id].keys[challenge.stage]].include?(event.message.content.downcase)
      finished = (challenge.stage + 1) >= 6
      challenge.update(stage: challenge.stage + 1)
      event.respond("Correct!")
      if finished
        end_time = Time.now.to_i
        challenge.update(end_time: end_time)
        event.respond("#{player.tribe.name} has finished the challenge with **#{end_time - challenge.start_time} seconds!**")
      else
        event.respond("Next up. Which animal is #{favorites[player.tribe.id].keys[player.tribe.challenges.first.stage]}'s favorite?")
      end
    else
      challenge.update(start_time: challenge.start_time - 10)
      event.respond("Incorrect! **+10 seconds penalty!**")

    end
  end

  BOT.command :start do |event|
    break unless event.user.id.player?
    player = Player.find_by(user_id: event.user.id)

    break unless player.tribe.challenges.size.positive?
    break unless event.channel.id == player.tribe.cchannel_id && player.tribe.challenges.first.start_time == nil
    event.respond("The timer has begun!")
    file = URI.parse('https://i.ibb.co/HpRgDs79/Wild-Animals-crosswords-1-page-0001.jpg').open
    BOT.send_file(event.channel, file, filename: 'puzzle.jpg')
  end

  BOT.command :end do |event|
    break unless event.user.id.player?
    player = Player.find_by(user_id: event.user.id)

    break unless player.tribe.challenges.size.positive?
    challenge = player.tribe.challenges.first
    time = Time.now.to_i
    break unless event.channel.id == player.tribe.cchannel_id && challenge.start_time != nil && challenge.first.end_time == nil
    challenge.update(end_time: time)

    event.respond("The timer has stopped! Your total time was **#{challenge.end_time - time} seconds.**")
  end

  BOT.command :start_ice do |event|
    break unless event.user.id.player?
    player = Player.find_by(user_id: event.user.id)

    break unless player.tribe.challenges.size.positive?

    break unless event.channel.id == player.tribe.cchannel_id && player.tribe.challenges.first.start_time == nil
    event.respond("**#{player.tribe.name}**'s timer for the challenge has begun!\nWhich animal is #{favorites[player.tribe.id].keys[player.tribe.challenges.first.stage]}'s favorite?")
    player.tribe.challenges.first.update(start_time: Time.now.to_i)
    return
  end

  BOT.command :begin_challenge do |event|
    break unless event.user.id.host?

    Setting.last.tribes.each do |tribe_id|
      Challenge.create(tribe_id: tribe_id)
      BOT.channel(Tribe.find_by(id: tribe_id).cchannel_id).send_embed do |embed|
        embed.title = '# Immunity Challenge No. 4'
        embed.description = "Once you feel properly equipped to do so, use the command `!start` to begin a timer and get your Crosswords Puzzle.\n\nThis puzzle will feature animals, and your task is to match each number to the image.\nSubmit your answers in this challenges channel, preferably in a list format.\n\n**The first castaway who writes the correct answer for an image earns a point!**\nAnd the castaway who has the most points within a tribe... earns Individual Immunity.\n\nAnd, at the end... the two tribes with **the most correct answers** will win. Time will be the tiebreaker."

      end
    end
    return
  end
  
end