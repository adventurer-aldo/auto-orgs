class Sunny

    BOT.command :vote, description: "Vote a seedling for Tribal Council" do |event, *args|
        # ===========================================================================================
        # Once votes are TOTAL_ALLOWED_VOTES == SUBMITTED VOTES, then enter Lock phase.
        # Once you lock, the Bot will make tribal council by itself.
        # It does not mean you can't change votes anymore. It merely means it will start early, unless
        # you need to rethink of something.
        player = nil

        break unless event.user.id.player?

        if [0,1].include? Setting.last.game_stage
            player = Player.find_by(user_id: event.user.id, season: Setting.last.season, status: ALIVE)
        else
            player = Player.find_by(user_id: event.user.id, season: Setting.last.season, status: 'Jury')
        end

        vote = Vote.where(player: player.id)
        council = Council.where(id: vote.map(&:council), stage: [0,1,3])
        if vote.exists? && council.exists?
            council = council.last
            updater = Vote.where(council: council.id).and(vote)
            vote = updater.first
            
            allowed_votes = vote.allowed
            if allowed_votes <= 0
                event.respond("You do not have any votes!")    
            else
                voted = vote.votes
                enemies = Vote.where(council: council.id).excluding(Vote.where(player: player.id)).map(&:player).map { |n| Player.find_by(id: n, status: 'In') }
                enemies.delete(nil)
                options = enemies.map(&:id)


                
                content = ""
                number = 0
                if allowed_votes > 1 && args[0]
                    
                    if args[0]
                        number = args[0].to_i - 1
                        number = 0 if number > allowed_votes - 1 || number < 0
                    end

                    if args[1]
                        content = args[1..args.size-1].join(' ')
                    end
                    
                elsif allowed_votes < 2 && args[0]
                    content = args.map(&:downcase).join(' ')
                end

                if content == ""
                    text = enemies.map do |en|
                        "**#{en.id}** — #{en.name}"
                    end

                    event.channel.send_embed do |embed|
                        embed.title = "Who would you like to vote?"
                        embed.description = text.join("\n")
                        embed.color = event.server.role(Tribe.find_by(id: player.tribe).role_id).color
                    end

                    event.user.await!(timeout: 40) do |await|
                        content = await.message.content.downcase
                        true
                    end
                end

                text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content }
                id_attempt = options.filter { |id| id == content.to_i }
                if text_attempt.size == 1
                    @target = Player.find_by(name: text_attempt[0], season: Setting.last.season, status: ALIVE)
                    voted[number] = @target.id
                elsif id_attempt.size == 1
                    @target = Player.find_by(id: id_attempt[0])
                    voted[number] = id_attempt[0]
                else
                    event.respond("There's no single seedling that matches that.") unless content == ''
                end

                

                if voted == vote.votes && content != ''
                    updater.update(votes: voted)
                    event.respond("You're now voting **#{@target.name}**.")
                else
                    "No vote was submitted..."
                end
            end
        end
    end

end