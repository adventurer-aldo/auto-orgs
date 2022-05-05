class Sunny

    BOT.command :inventory, description: 'Shows your items and current votes.' do |event|
        break unless event.user.id.player?

        player = nil
        player = if [0, 1].include? Setting.last.game_stage
                     Player.find_by(user_id: event.user.id, season: Setting.last.season, status: ALIVE)
                 else
                     Player.find_by(user_id: event.user.id, season: Setting.last.season, status: 'Jury')
                 end
        break if player.nil?

        break unless [player.confessional,player.submissions].include? event.channel.id

        items = Item.where(owner: player.id)

        text = ''

        items = items.map do |item|
            "**#{item.name}**\n#{item.description}\n**Code:** `#{item.code}`"
        end

        text << items.join("\n\n")

        vote = Vote.where(player: player.id)
        council = Council.where(id: vote.map(&:council), stage: Array(0..3))
        if vote.exists? && council.exists?
            council = council.first
            vote = Vote.where(council: council.id).and(vote).first.votes
            vote.map! do |parch|
                if parch.zero?
                    if vote.size == 1
                        'No One'
                    elsif vote.size > 1
                        "Vote #{vote.index(parch) + 1}: No One"
                    end
                else
                    if vote.size == 1
                        Player.find_by(id: parch).name
                    elsif vote.size > 1
                        "Vote #{vote.index(parch) + 1} : #{Player.find_by(id: parch).name}"
                    end
                end
            end

            text << "\n\n**For the Tribal Council, currently voting:**\n#{vote.join("\n")}"
        end

        event.channel.send_embed do |embed|
            embed.title = "#{player.name}'s Inventory"
            embed.description = text
            tribe = Tribe.find_by(id: player.tribe)
            embed.color = event.server.role(tribe.role_id).color if tribe
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use `!give CODE` to send your items to other players or `!play CODE` to play it yourself.')
        end


    end

end