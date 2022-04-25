class Sunny

    def self.eliminate(loser,event)
        rank = Player.where(season: Setting.last.season, status: ALIVE).size
        tribe = Tribe.find_by(id: loser.tribe)
        if Setting.last.game_stage == 1
            loser.update(status: 'Jury', inventory: [], rank: rank)
            user = BOT.user(loser.user_id).on(event.server)
            
            user.remove_role(tribe.role_id)
            user.remove_role(CASTAWAY)
            user.add_role(JURY)
        else
            loser.update(status: 'Out', inventory: [], rank: rank)
            user = BOT.user(loser.user_id).on(event.server)
            
            user.remove_role(tribe.role_id)
            user.remove_role(CASTAWAY)
            user.add_role(PREJURY)
        end

        alliances = Alliance.where("#{loser.id} = ANY (players)")
        if alliances.exist?
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
        end
        conf = BOT.channel(loser.confessional)
        conf.name = "#{rank}th-" + conf.name
        conf.sort_after(BOT.channel(CONFESSIONALS).children[(rank*2)-3])
        subm = BOT.channel(loser.submissions)
        subm.name = "#{rank}th-" + subm.name
        subm.sort_after(BOT.channel(CONFESSIONALS).children[(rank*2)-2])
        Player.where(status: ALIVE).update(status: 'In')
        event.server.role(IMMUNITY).members.each { |immune| immune.on(event.server).remove_role(IMMUNITY) }
    end

end