class Sunny

    BOT.command :vote do |event, *args|
        # Need a vote command. Players can only be in one tribal council at a time.
        # ===========================================================================================
        # Vote should only be available if there's a vote with the player's id,
        # while checking for a council that is in stage 0 [Before 12h, can swap immunity or SA] or
        # stage 1 [After 12h, can't swap immunity or use safety advantage]
        # ===========================================================================================
        # If there's a council that meets those two conditions, plus the player has a vote ID that
        # matches, you can vote.
        # ===========================================================================================
        # First check if the player has enough votes. If you have 0, just...deny it.
        # If you have more than one vote, you HAVE to use either 1 or 2 as the first arg.
        # ===========================================================================================
        # Further optional condition: 
        # Use player name for identification for vote. If there's more than one player that matches a 
        # name, you'll have to use the ID.
        # If you fail even at that, well, just don't vote.
        # ===========================================================================================
        # Once votes are TOTAL_ALLOWED_VOTES == SUBMITTED VOTES, then enter Lock phase.
        # Once you lock, the Bot will make tribal council by itself.
        # It does not mean you can't change votes anymore. It merely means it will start early, unless
        # you need to rethink of something.

        player = Player.find_by(user_id: event.user.id, season: Setting.last.season, status: ALIVE)
        vote = Vote.where(player: player.id)
        council = Council.where(id: vote.map(&:council), stage: [0,1])
        if vote.exists? && council.exists?
            council = council.first
            updater = Vote.where(council: council.id).and(vote)
            vote = updater.first
            
            allowed_votes = vote.allowed
            if allowed_votes <= 0
                event.respond("You do not have any votes!")    
            else
                voted = vote.votes
                enemies = Player.where(season: Setting.last.season, tribe: player.tribe, status: 'In').excluding(player).order(id: :asc)
                options = enemies.map(&:id)

                text = enemies.map do |en|
                    "**#{en.id}** — #{en.name}"
                end

                event.channel.send_embed do |embed|
                    embed.title = "Who would you like to vote?"
                    embed.description = text.join("\n")
                    embed.color = event.server.role(Tribe.find_by(id: player.tribe).role_id).color
                end

                number = args[0].to_i - 1
                number = 0 if number > allowed_votes - 1 || number < 0

                event.user.await!(timeout: 40) do |await|
                    text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? await.message.content.downcase }
                    id_attempt = options.filter { |id| id == await.message.content.to_i }
                    if text_attempt.size == 1
                        @target = Player.find_by(name: text_attempt[0], season: Setting.last.season, status: ALIVE)
                        voted[number] = @target.id
                        event.respond("YOURE IN THE AWAIT BABY")
                    elsif id_attempt.size == 1
                        voted[number] = id_attempt[0]
                        @target = Player.find_by(id: id_attempt[0])
                        event.respond("YOURE IN THE AWAIT BABY")
                    else
                        event.respond("There's no seedling that matches that.")
                    end
                    
                end
                

                if voted == vote.votes
                    "No vote was submitted..."
                else
                    updater.update(votes: voted)
                    event.respond("You're now voting **#{@target.name}**.")
                end
            end
        end
    end

end