class Sunny

    BOT.command :tribal_stage, description: "Changes the Tribal Council stage to 1 (after 12h) to all those who have 0." do |event|
        if [0,1].include? Setting.last.game_stage
            Council.where(stage: 0).update(stage: 1)
        else
            Council.where(stage: 0).update(stage: 2)
        end
    end

    BOT.command :rocks, description: "Quick and simple goes to rocks." do |event|
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
        seeds = Vote.where(council: council.id).map(&:player).map { |n| Player.find_by(id: n, status: 'Idoled') }
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
    end

    BOT.command :count, description: "Counts the votes inside a Tribal Council channel." do |event|
        break unless HOSTS.include? event.user.id
        council = Council.find_by(channel_id: event.channel.id)
        break if council.id == nil
        break unless [1,3].include? council.stage
        event.message.delete
        event.channel.start_typing
        sleep(2)
        rank = Player.where(season: Setting.last.season, status: ALIVE).size
        total = Player.where(season: Setting.last.season).size
        if council.stage > 2
            event.respond("**It's time to read the votes, once again!**")
            event.channel.start_typing
            sleep(2)
            event.respond("Your votes can no longer be changed.")
        else
            event.respond("**It is time for the F#{rank} read-off!**")
            council.update(stage: 2)
            event.channel.start_typing
            sleep(2)
            event.respond("Your votes can no longer be changed.")
        end
        event.channel.start_typing
        sleep(1)
        event.respond("...")
        event.channel.start_typing
        sleep(2)
        if council.stage == 2 && rank > 4
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
        majority = (Float(all_votes.size + 1)/2.0).round

        loop do
            if all_votes.size > 1 && vote_count[all_votes[0]] + 1 != majority
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
                    event.respond("**#{COUNTING[total - rank]} seedling eliminated from Maskvivor and #{COUNTING[Player.where(status: 'Jury', season: Setting.last.season).size].downcase} member of the Jury is...**")
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
                        case council.stage
                        when 2
                            council.update(stage: 3)
                            event.respond("Everyone but the tied up seedlings will enter in a revote, each with only one available vote.")
                            event.channel.start_typing
                            sleep(3)
                            event.respond("You will only be able to vote the seedlings tied.")

                            Player.where(season: Setting.last.season, status: 'Idoled').update(status: 'Immune')
                            immunes = Player.where(status: 'Immune').map(&:id)
                            
                            vote_count.each do |k,v|
                                if v == vote_count.values.max
                                    Vote.find_by(player: k, council: council.id).update(allowed: 0, votes: []) 
                                else
                                    Vote.find_by(player: k, council: council.id).update(allowed: 1, votes: [0]) 
                                end
                            end
                            Vote.where(council: council.id, allowed: 1).excluding(Vote.where(player: immunes)).each do |revote|
                                Player.find_by(id: revote.player).update(status: 'Idoled')
                            end
                            
                        when 4
                            event.channel.start_typing
                            sleep(3)
                            event.respond("We'll be drawing **ROCKS**")
                            event.channel.start_typing
                            sleep(3)
                            event.respond("The Seedling that draws the purple rock will be out of the game immediately.")
                            event.channel.start_typing
                            sleep(3)
                            Player.find_by(status: 'In').update(status: 'Immune')
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
                                end
                            end
                        end
                    end

                else
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
                end


            else
                break
            end
            break if vote_count.values.max == majority || all_votes.size == 0
        end
        break if !(vote_count.values.count(vote_count.values.max) > 1) 

        loser ||= seed
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
        BOT.channel(loser.confessional).name = "#{rank}th-" + BOT.channel(loser.confessional).name
        BOT.channel(loser.submissions).name = "#{rank}th-" + BOT.channel(loser.submissions).name
        Player.where(status: ALIVE).update(status: 'In')

        break if DEAD.include? loser.status
    end

end