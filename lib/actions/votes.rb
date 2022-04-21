class Sunny

    BOT.command :vote, description: "Vote a seedling for Tribal Council" do |event, *args|
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
                    elsif id_attempt.size == 1
                        @target = Player.find_by(id: id_attempt[0])
                        voted[number] = id_attempt[0]
                    else
                        await.respond("There's no single seedling that matches that.")
                    end

                    true
                end
                

                if voted == vote.votes
                    updater.update(votes: voted)
                    event.respond("You're now voting **#{@target.name}**.")
                else
                    "No vote was submitted..."
                end
            end
        end
    end

end