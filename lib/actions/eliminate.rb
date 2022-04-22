class Sunny

    BOT.command :eliminate, description: "Removes a castaway from the game." do |event, *args|
        break unless HOSTS.include? event.user.id
        content = args.join(' ')
        enemies = Player.where(season: Setting.last.season)

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
            tribe = Tribe.find_by(id: loser.tribe)
            if Setting.last.game_stage == 1
                loser.update(status: 'Jury', inventory: [])
                user = BOT.user(loser.user_id).on(event.server)
                
                user.remove_role(tribe.role_id)
                user.remove_role(964564440685101076)
                user.add_role(965717073454043268)
            else
                loser.update(status: 'Out', inventory: [])
                user = BOT.user(loser.user_id).on(event.server)
                
                user.remove_role(tribe.role_id)
                user.remove_role(964564440685101076)
                user.add_role(965717099202904064)
            end
            council.update(stage: 5)
            alliances = Alliance.where("#{loser.id} = ANY (players)")
            alliances.each do |alliance|
                alliance.update(players: alliance.players - [loser.id])
                if alliance.players.size < 4 || alliance.players.size == event.server.role(Tribe.find_by(id: loser.tribe).role_id).members.size
                    channel = BOT.channel(alliance.channel_id)
                    channel.parent = ARCHIVE
                    BOT.send_message(channel.id, ":ballot_box_with_check: **This channel has been archived!**")
                    channel.permission_overwrites.each do |role, perms|
                        unless role.id == loser.user_id
                            channel.define_overwrite(event.server.member(role), 3072, 0)
                        else
                            channel.define_overwrite(event.server.member(loser.user_id), 0, 3072)
                        end
                    end
                end
            end
            rank = Player.where(season: Setting.last.season, status: ALIVE).size
            event.respond("#{loser.name} has been eliminated.")
            BOT.channel(loser.confessional).name = "#{rank}th-" + BOT.channel(loser.confessional).name
            BOT.channel(loser.submissions).name = "#{rank}th-" + BOT.channel(loser.submissions).name
            Player.where(status: ALIVE).update(status: 'In')
        end
        return
    end

    BOT.command :rocks, description: "Quick and simple goes to rocks." do |event, *args|
        break unless HOSTS.include? event.user.id
        council = Council.find_by(channel_id: event.channel.id)
        break if council.id == nil
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
        if args.join(' ').downcase == 'in'
            seeds = Vote.where(council: council.id).map(&:player).map { |n| Player.find_by(id: n, status: 'In') }
        else
            seeds = Vote.where(council: council.id).map(&:player).map { |n| Player.find_by(id: n, status: 'Idoled') }
        end
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
                event.respond("Unfortunately, **#{seed.name}** is now out of the game.")
                tribe = Tribe.find_by(id: seed.tribe)
                if Setting.last.game_stage == 1
                    seed.update(status: 'Jury')
                    user = BOT.user(seed.user_id).on(event.server)
                    
                    user.remove_role(tribe.role_id)
                    user.remove_role(964564440685101076)
                    user.add_role(965717073454043268)
                else
                    seed.update(status: 'Out')
                    user = BOT.user(seed.user_id).on(event.server)
                    
                    user.remove_role(tribe.role_id)
                    user.remove_role(964564440685101076)
                    user.add_role(965717099202904064)
                end
                council.update(stage: 4)
                alliances = Alliance.where("#{seed.id} = ANY (players)")
                alliances.each do |alliance|
                    alliance.update(players: alliance.players - [seed.id])
                    if alliance.players.size < 4 || alliance.players.size == event.server.role(Tribe.find_by(id: seed.tribe).role_id).members.size
                        channel = BOT.channel(alliance.channel_id)
                        channel.parent = ARCHIVE
                        BOT.send_message(channel.id, ":ballot_box_with_check: **This channel has been archived!**")
                        channel.permission_overwrites.each do |role, perms|
                            channel.define_overwrite(event.server.member(seed.user_id), 0, 3072)
                        end
                    end
                end
                rank = Player.where(season: Setting.last.season, status: ALIVE).size
                BOT.channel(seed.confessional).name = "#{rank}th-" + BOT.channel(seed.confessional).name
                BOT.channel(seed.submissions).name = "#{rank}th-" + BOT.channel(seed.submissions).name
                Player.where(status: ALIVE).update(status: 'In')
            end
        end
        return
    end
    
end