class Sunny

    BOT.command :inventory, description: "Shows your items and current votes." do |event|
        break unless event.user.id.player?
        player = nil
        if [0,1].include? Setting.last.game_stage
            player = Player.find_by(user_id: event.user.id, season: Setting.last.season, status: ALIVE)
        else
            player = Player.find_by(user_id: event.user.id, season: Setting.last.season, status: 'Jury')
        end
        vote = Vote.where(player: player.id)
        council = Council.where(id: vote.map(&:council), stage: [0,1,2,3])
        if vote.exists? && council.exists?
            council = council.first
            vote = Vote.where(council: council.id).and(vote).first.votes
            vote.map! do |parch|
                if parch == 0
                    if vote.size == 1
                        "No One"
                    elsif vote.size > 1
                        "Vote " + (vote.index(parch) + 1).to_s + ": No One"
                    end
                else
                    if vote.size == 1
                        Player.find_by(id: parch).name
                    elsif vote.size > 1
                        "Vote " + (vote.index(parch) + 1).to_s + ": " + Player.find_by(id: parch).name
                    end
                end
            end

            event.respond("**You're currently voting:**\n" + vote.join("\n"))
        end

    end

end