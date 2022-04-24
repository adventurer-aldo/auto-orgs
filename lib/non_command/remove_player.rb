class Sunny

    def self.eliminate(loser,event)
        tribe = Tribe.find_by(id: loser.tribe)
        if Setting.last.game_stage == 1
            loser.update(status: 'Jury', inventory: [])
            user = BOT.user(loser.user_id).on(event.server)
            
            user.remove_role(tribe.role_id)
            user.remove_role(CASTAWAY)
            user.add_role(JURY)
        else
            loser.update(status: 'Out', inventory: [])
            user = BOT.user(loser.user_id).on(event.server)
            
            user.remove_role(tribe.role_id)
            user.remove_role(CASTAWAY)
            user.add_role(PREJURY)
        end

        alliances = Alliance.where("#{loser.id} = ANY (players)")
        alliances.each do |alliance|
            alliance.update(players: alliance.players - [loser.id])
            channel = BOT.channel(alliance.channel_id)
            if alliance.players.size < 4 || alliance.players.size == event.server.role(Tribe.find_by(id: loser.tribe).role_id).members.size
                channel.parent = ARCHIVE
                BOT.send_message(channel.id, ":ballot_box_with_check: **This channel has been archived!**")
                channel.permission_overwrites.each do |role, perms|
                    unless role == EVERYONE
                        channel.define_overwrite(event.server.member(role), 0, 3072)
                    end
                end
                
            else
                BOT.send_message(channel.id, ":broken_heart: **#{loser.name} removed...**")
                channel.permission_overwrites.each do |role, perms|
                    unless role == EVERYONE
                        unless role == loser.user_id
                            channel.define_overwrite(event.server.member(role), 3072, 0)
                        else
                            channel.define_overwrite(event.server.member(loser.user_id), 0, 3072)
                        end
                    end

                end
            end

        end
        BOT.channel(loser.confessional).name = "#{rank}th-" + BOT.channel(loser.confessional).name
        BOT.channel(loser.submissions).name = "#{rank}th-" + BOT.channel(loser.submissions).name
        Player.where(status: ALIVE).update(status: 'In')
    end

end