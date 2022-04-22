class Sunny

    BOT.command :eliminate, description: "Removes a castaway from the game." do |event, *args|
        break unless HOSTS.include? event.user.id
        content = args.join(' ')
        enemies = Player.where(season: Setting.last.season)

        puts number.to_s + " is num"
        puts content.to_s + " is content"
        text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content }
        id_attempt =  enemies.map(&:id).filter { |id| id == content.to_i }
        if text_attempt.size == 1
            @target = Player.find_by(name: text_attempt[0], season: Setting.last.season, status: ALIVE)
            puts @target.name + " is target"
            voted[number] = @target.id
        elsif id_attempt.size == 1
            @target = Player.find_by(id: id_attempt[0])
            puts @target.name + " is target"
            voted[number] = id_attempt[0]
        else
            event.respond("There's no single seedling that matches that.") unless content == ''
        end
        
        if @target
            loser = @target
            tribe = Tribe.find_by(id: loser.tribe)
            if Setting.last.game_stage == 1
                loser.update(status: 'Jury')
                user = BOT.user(loser.user_id).on(event.server)
                
                user.remove_role(tribe.role_id)
                user.remove_role(964564440685101076)
                user.add_role(965717073454043268)
            else
                loser.update(status: 'Out')
                user = BOT.user(loser.user_id).on(event.server)
                
                user.remove_role(tribe.role_id)
                user.remove_role(964564440685101076)
                user.add_role(965717099202904064)
            end
            council.update(stage: 5)
            alliances = Alliance.where("#{loser.id} = ANY (players)")
            alliances.each do |alliance|
                alliance.update(players: alliance.players - [loser.id])
                if alliance.players.size < 3 || alliance.players.size == event.server.role(Tribe.find_by(id: loser.tribe).role_id).members.size
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
            BOT.channel(loser.confessional).name = "#{rank}th-" + BOT.channel(loser.confessional).name
            BOT.channel(loser.submissions).name = "#{rank}th-" + BOT.channel(loser.submissions).name
            Player.where(status: ALIVE).update(status: 'In')
        end
    end

end