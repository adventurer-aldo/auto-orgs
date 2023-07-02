class Sunny
  BOT.command :eliminate, description: 'Removes a castaway from the game.' do |event, *args|
    break unless HOSTS.include? event.user.id

    content = args.join(' ')
    enemies = Player.where(season: Setting.last.season, status: ALIVE)

    text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content.downcase }
    id_attempt = enemies.map(&:id).filter { |id| id == content.to_i }
    target = nil
    if text_attempt.size == 1
      target = Player.find_by(name: text_attempt[0])
    elsif id_attempt.size == 1
      target = Player.find_by(id: id_attempt[0])
    else
      event.respond("There's no single castaway that matches that.") unless content == ''
    end

    if target
      loser = target
      eliminate(loser,event)
      Council.all.update(stage: 5)
      event.respond("#{loser.name} has been eliminated.")
    end
    return
  end

  BOT.command :rocks, description: 'Quick and simple goes to rocks.' do |event, *args|
    break unless HOSTS.include? event.user.id

    council = Council.find_by(channel_id: event.channel.id)
    break if council.id.nil?

    event.message.delete
    event.channel.start_typing
    sleep(3)
    event.respond("We'll be drawing **ROCKS**")
    event.channel.start_typing
    sleep(3)
    event.respond('The Seedling that draws the purple rock will be out of the game immediately.')
    event.channel.start_typing
    sleep(3)
    stat =  if args.join(' ').downcase == 'in'
              'In'
            else
              'Idoled'
            end

    seeds = Vote.where(council_id: council.id).map(&:player).map { |n| Player.find_by(id: n, status: stat) }
    seeds.delete(nil)

    event.respond("This will be between #{seeds.map(&:name).join(', ')}")
    event.channel.start_typing
    sleep(3)
    event.respond("Let's get to it!")
    seeds.delete(nil)
    rocks = seeds.map { 0 }
    rocks[0] = 1
    rocks.shuffle!
    seeds.each do |seed|
      event.channel.start_typing
      sleep(3)
      event.respond("#{seed.name} draws a rock...")
      event.channel.start_typing
      sleep(3)
      event.respond('...')
      event.channel.start_typing
      sleep(3)
      if rocks[seeds.index(seed)].zero?
        event.respond("It's a white rock! #{seed.name} is safe.")
        event.respond '.'
      else
        event.respond('...')
        event.channel.start_typing
        sleep(3)
        event.respond("It's a **purple rock**.")
        event.channel.start_typing
        sleep(3)
        eliminate(seed,event)
        event.respond("#{seed.name} has unfortunately been eliminated from the game.")
        council.update(stage: 5)
      end
      break unless rocks[seeds.index(seed)].zero?
    end
    return

  end
end
