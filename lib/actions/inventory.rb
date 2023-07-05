class Sunny
  BOT.command :inventory, description: 'Shows your items and current votes.' do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break if player.nil?

    break unless [player.confessional, player.submissions].include? event.channel.id

    text = Item.where(owner: player.id).map do |item|
      "**#{item.name}**\n#{item.description}\n**Code:** `#{item.code}`"
    end.join("\n\n")

    vote = player.votes
    council = Council.where(id: vote.map(&:council_id), stage: Array(0..3))
    if vote.exists? && council.exists?
      council = council.first
      vote = Vote.where(council_id: council.id).and(vote).first.votes
      vote.map! do |parch|
        if parch.zero?
          if vote.size == 1
            'No One'
          elsif vote.size > 1
            "Vote #{vote.index(parch) + 1}: No One"
          end
        elsif vote.size == 1
          Player.find_by(id: parch).name
        elsif vote.size > 1
          "Vote #{vote.index(parch) + 1} : #{Player.find_by(id: parch).name}"
        end
      end

      text << "\n\n**For the Tribal Council, currently voting:**\n#{vote.join("\n")}"
    end

    event.channel.send_embed do |embed|
      embed.title = "#{player.name}'s Inventory"
      embed.description = text
      embed.color = event.server.role(player.tribe.role_id).color if player.tribe
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use `!give CODE` to send your items to other castaways or `!play CODE` to play it yourself.')
    end
  end
end
