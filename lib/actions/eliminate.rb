class Sunny

    BOT.command :eliminate, description: "Removes a castaway from the game." do |event, *args|
        break unless HOSTS.include? event.user.id
        content = args.join(' ')
        enemies = Player.where(season: Setting.last.season)
        rank = Player.where(season: Setting.last.season, status: ALIVE).size

        text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content }
        id_attempt =  enemies.map(&:id).filter { |id| id == content.to_i }
        if text_attempt.size == 1
            @target = Player.find_by(name: text_attempt[0], season: Setting.last.season, status: ALIVE)
            puts @target.name + " is target"
        elsif id_attempt.size == 1
            @target = Player.find_by(id: id_attempt[0])
            puts @target.name + " is target"
        else
            event.respond("There's no single seedling that matches that.") unless content == ''
        end
        
        if @target
            loser = @target
            eliminate(loser,event)
            Council.all.update(status: 5)
            event.respond("#{loser.name} has been eliminated.")
        end
        return
    end

    BOT.command :rocks, description: "Quick and simple goes to rocks." do |event, *args|
        break unless HOSTS.include? event.user.id
        council = Council.find_by(channel_id: event.channel.id)
        break if council.id == nil
        rank = Player.where(season: Setting.last.season, status: ALIVE).size

        event.message.delete
        event.channel.start_typing
        sleep(3)
        event.respond("We'll be drawing **ROCKS**")
        event.channel.start_typing
        sleep(3)
        event.respond("The Seedling that draws the purple rock will be out of the game immediately.")
        event.channel.start_typing
        sleep(3)

        seeds = nil
        stat = nil
        if args.join(' ').downcase == 'in'
            stat = 'In'
        else
            stat = 'Idoled'
        end

        seeds = Vote.where(council: council.id).map(&:player).map { |n| Player.find_by(id: n, status: stat) }
        
        event.respond("This will be between #{seeds.map(&:name).join(', ')}")
        event.channel.start_typing
        sleep(3)
        event.respond("Let's get to it!")
        seeds.delete(nil)
        rocks = seeds.map { |n| 0 }
        rocks[0] = 1
        rocks.shuffle!
        seeds.each do |seed|
            event.channel.start_typing
            sleep(3)
            event.respond("#{seed.name} draws a rock...")
            event.channel.start_typing
            sleep(3)
            event.respond("...")
            event.channel.start_typing
            sleep(3)
            if rocks[seeds.index(seed)] == 0
                event.respond("It's a white rock! #{seed.name} is safe.")
            else
                event.respond("...")
                event.channel.start_typing
                sleep(3)
                event.respond("It's a **purple rock**.")
                event.channel.start_typing
                sleep(3)
                eliminate(seed,event)
            end
        end
        return
    end
    
end