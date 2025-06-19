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
  
  BOT.command :snowflake do |event, *args|
    event.respond "Please provide exactly two message IDs." if args.size != 2
    break if args.size != 2

    id1, id2 = args.map(&:to_i)
    begin
      m1 = event.channel.load_message(id1)
      m2 = event.channel.load_message(id2)
      diff = (m1.timestamp - m2.timestamp).abs.to_i
      event.respond "There are #{diff} seconds between the messages."
    rescue
      event.respond "I couldn't find one or both messages. Make sure the IDs are from this channel."
    end
  end


  BOT.command :start do |event|
    break unless event.user.id.player?
    player = Player.find_by(user_id: event.user.id)

    break unless player.individuals.size.positive?
    individual = player.individuals.first
    break unless event.channel.id == player.tribe.cchannel_id && individual.start_time == nil
    event.respond("The timer for you has begun!")
    event.respond("https://www.jigsawplanet.com/?rc=play&pid=1d7360c0eff3")
    individual.update(start_time: Time.now.to_i)
  end

  BOT.command :end do |event|
    break unless event.user.id.player?
    player = Player.find_by(user_id: event.user.id)

    break unless player.individuals.size.positive?
    individual = player.individuals.first
    time = Time.now.to_i
    break unless event.channel.id == player.submissions && individual.start_time != nil && individual.end_time == nil
    individual.update(end_time: time)

    event.respond("The timer has stopped! Your total time was **#{time - individual.start_time} seconds.**")
    BOT.channel(player.tribe.cchannel_id).send_message("#{player.name}} has solved the puzzle with... **#{time - individual.start_time } seconds!**")
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