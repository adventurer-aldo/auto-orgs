class Sunny

    BOT.command :tribal_stage, description: "Changes the Tribal Council stage to 1 (after 12h) to all those who have 0." do |event|
        Council.where(stage: 0).update(stage: 1)
    end

    BOT.command :count, description: "Counts the votes inside a Tribal Council channel." do |event|
        council = Council.find_by(channel_id: event.channel.id)
        if [1,2].include? council.stage
            event.channel.start_typing
            sleep(2)
            rank = Player.where(season: Setting.last.season, status: ALIVE).size
            total = Player.where(season: Setting.last.season).size
            event.respond("**It is time for the F#{rank} read-off!**")
            event.channel.start_typing
            sleep(2)
            event.respond("Your votes can no longer be changed.")
            event.channel.start_typing
            sleep(1)
            event.respond("...")
            event.channel.start_typing
            sleep(2)
            if council.stage < 2
                event.respond("Now, if anyone would like to play a **Hidden Immunity Idol**...")
                event.channel.start_typing
                sleep(2)
                event.respond("This is the time to do it.")
                10.times do
                    event.channel.start_typing
                    sleep(1)
                    event.respond("...")
                end
            end
            event.respond("Alright. Once the votes are read, the decision is final and the seedling voted off will be asked to leave the Tribal Council area immediately.")
            all_votes = []
            counted_votes = []
            vote_count = {}

            voters = Vote.where(council: council.id)
            voters.each do |vote|
                sub = vote.votes.map do |mapping|
                    if mapping == 0
                        vote.player
                    else
                        mapping
                    end
                end
                vote.update(votes: sub)
                all_votes += sub
                vote_count[vote.player] = 0
            end
            all_votes.shuffle!
            majority = (Float(voters.size)/2.0).round

            loop do
                if all_votes.size > 1
                    event.channel.start_typing
                    sleep(2)
                    event.respond(COUNTING[counted_votes.size] + ' vote...')
                    event.channel.start_typing
                    sleep(2)
                    votee = Player.find_by(id: all_votes[0])
                    event.respond(BOT.user(votee.user_id).mention)
                    if votee.status == 'Idoled'
                        event.channel.start_typing
                        sleep(2)
                        event.respond("Does not count!")
                    else
                        counted_votes += [all_votes[0]]
                        vote_count[all_votes[0]] += 1
                    end
                    all_votes.delete_at(0)
                    event.channel.start_typing
                    sleep(2)
                    if vote_count.values.count(vote_count.values.max) > 1
                        revel = []
                        vote_count.each do |k,v|
                            if v == 1
                                revel << "#{v} vote #{Player.find_by(id: k).name}"
                            elsif v > 1
                                revel << "#{v} votes #{Player.find_by(id: k).name}"
                            end
                        end
                        revel = "That's " + revel.join(', ')
                        event.respond(revel)
                        event.channel.start_typing
                        sleep(2)
                        if all_votes.size > 1
                            event.respond("**#{all_votes.size} votes left.**")
                        elsif all_votes.size == 1
                            event.respond("**ONE VOTE LEFT**")
                        end
                    end
                elsif all_votes.size == 1 || vote_count[all_votes[0]] + 1 == majority
                    event.channel.start_typing
                    sleep(2)
                    if Setting.last.game_stage == 0
                        event.respond("**The #{COUNTING[total - rank]} seedling eliminated from Maskvivor is...**")
                    elsif Setting.last.game_stage == 1
                        event.respond("**The #{COUNTING[total - rank]} seedling eliminated from Maskvivor and #{COUNTING[Player.where(status: 'Jury', season: Setting.last.season).size]} member of the Jury is...**")
                    else
                        event.respond("**THE #{event.server.role(966730313537581076).mention} OF MASKVIVOR S1 VEGGIE SQUADS IS...**")
                    end
                    sleep(5)
                    event.respond(BOT.user(Player.find_by(id: all_votes[0]).user_id).mention)
                    counted_votes += [all_votes[0]]
                    vote_count[all_votes[0]] += 1
                    all_votes.delete_at(0)
                    event.channel.start_typing
                    sleep(2)
                    if vote_count.values.count(vote_count.values.max) > 1
                        event.respond("**We're tied!**")
                        event.channel.start_typing
                        sleep(3)
                        event.respond("Here's how we'll do this.")
                        if rank == 4
                            event.channel.start_typing
                            sleep(3)
                            event.respond("We'll do a **Firemaking Challenge.**")
                            event.channel.start_typing
                            sleep(3)
                            event.respond("The winner will get to move on to the **Final 3**.")
                            event.respond("#{BOT.user(HOSTS.sample).mention} can take it from here.")
                        else
                            event.channel.start_typing
                            sleep(3)
                            case Setting.last.game_stage
                            when 0
                                Setting.last.update(game_stage: 1)
                                event.respond("Everyone but the tied up seedlings will enter in a revote, each with only one available vote.")
                                event.channel.start_typing
                                sleep(3)
                                event.respond("You will only be able to vote the seedlings tied.")
                                Player.where(season: Setting.last.season, status: 'Idoled').update(status: 'Immune')
                                immunes = Player.where(status: 'Immune').map(&:id)
                                Vote.where(council: council.id).excluding(Vote.where(player: immunes)).update(status: 'Idoled')
                                vote_count.each do |k,v|
                                    Vote.find_by(player: k, council: council.id).update(allowed: 0, votes: []) if v == vote_count.values.max
                                end
                            when 1
                                event.channel.start_typing
                                sleep(3)
                                event.respond("We'll be drawing **ROCKS**")
                                event.channel.start_typing
                                sleep(3)
                                event.respond("The Seedling that draws the purple rock will be out of the game immediately.")
                                event.channel.start_typing
                                sleep(3)
                                event.respond("This will be between")
                                event.channel.start_typing
                                sleep(3)
                                event.respond("Let's get to it!")
                                seeds = Player.where(status: 'Idoled')
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
                                        alliances = Alliance.where("#{loser.id} = ANY (players)")
                                        alliances.each do |alliance|
                                            alliance.update(players: alliance.players - [loser.id])
                                            if alliance.players.size < 3 || alliance.players.size == event.server.role(Tribe.find_by(id: loser.tribe).role_id).members
                                                channel = BOT.channel(alliance.channel_id)
                                                channel.parent = ARCHIVE
                                                BOT.send_message(channel.id, ":ballot_box_with_check: **This channel has been archived!**")
                                                channel.permission_overwrites.each do |role, perms|
                                                    channel.define_overwrite(event.server.member(loser.user_id), 0, 3072)
                                                end
                                            end
                                        end
                                    end
                                    break if DEAD.include? seed.status
                                end
                            end
                        end

                    else
                        event.respond(vote_count.to_s)
                        loser = Player.find_by(id: vote_count.keys[vote_count.values.index(vote_count.values.max)])
                        event.respond("**#{loser.name}**")
                        event.channel.start_typing
                        sleep(3)
                        event.respond("It's time to go.")
                        event.channel.start_typing
                        sleep(3)
                        event.respond("Any final words?")
                        sleep(3)
                        event.respond("**#{loser.name}...The tribe has spoken.**")
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
                        alliances = Alliance.where("#{loser.id} = ANY (players)")
                        alliances.each do |alliance|
                            alliance.update(players: alliance.players - [loser.id])
                            if alliance.players.size < 3 || alliance.players.size == event.server.role(Tribe.find_by(id: loser.tribe).role_id).members
                                channel = BOT.channel(alliance.channel_id)
                                channel.parent = ARCHIVE
                                BOT.send_message(channel.id, ":ballot_box_with_check: **This channel has been archived!**")
                                channel.permission_overwrites.each do |role, perms|
                                    channel.define_overwrite(event.server.member(loser.user_id), 0, 3072)
                                end
                            end
                        end
                    end


                else
                    break
                end
                break if vote_count.values.max == majority || all_votes.size == 0
            end
        end
    end

end