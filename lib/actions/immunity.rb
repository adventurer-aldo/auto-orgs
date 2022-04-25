class Sunny

    BOT.command :immunity, description: "Grants immunity to all members of a role and the mentioned users." do |event|
        break unless HOSTS.include? event.user.id
        players = []
        
        unless event.message.mentions.size < 1
            event.message.mentions.each do |user| 
                players << Player.find_by(user_id: user.id, season: Setting.last.season)
            end
        end

        unless event.message.role_mentions.size < 1
            event.message.role_mentions.each do |role|
                role.members.each do |member|
                    players << Player.find_by(user_id: member.id, season: Setting.last.season)
                end
            end
        end

        players.each do |player|
            next if player == nil
            player.update(status: 'Immune')
        end

        if players == []
            event.respond("No players were found...")
        else
            event.respond("Immunity was given!")
        end
        return

    end

end