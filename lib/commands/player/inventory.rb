class Sunny
  BOT.command :inventory, description: 'Shows your items and current votes.' do |event|
    break unless event.user.id.player? || event.user.id.host?

    player = event.user.id.host? ? Player.find_by(submissions: event.channel.id) : Player.find_by(user_id: event.user.id, season_id: Setting.season_id, status: ALIVE)
    break if player.nil?

    break unless [player.confessional, player.submissions].include? event.channel.id

    text = player.items.map do |item|
      "**#{item.name}**\n#{item.description}\n**Code:** `#{item.code}`"
    end.join("\n\n")

    vote = player.votes
    council = Council.where(id: vote.map(&:council_id), stage: Array(0..3))
    if vote.exists? && council.exists?
      council = council.first
      vote_record = Vote.where(council_id: council.id).and(vote).first
      votes = Array(vote_record.votes)
      parchments = Array(vote_record.parchments)
      vote_lines = votes.each_with_index.map do |target_id, index|
        target = target_id.zero? ? 'No One' : Player.find_by(id: target_id)&.name || "Unknown (#{target_id})"
        prefix = votes.size == 1 ? '' : "Vote #{index + 1}: "
        parchment = parchments[index]
        parchment_text = parchment && parchment != '0' ? "\nParchment: #{parchment}" : "\nParchment: Not submitted"

        "#{prefix}#{target}#{parchment_text}"
      end

      text << "\n\n**For the Tribal Council, currently voting:**\n#{vote_lines.join("\n")}"
    end

    event.channel.send_embed do |embed|
      embed.title = "#{player.name}'s Inventory"
      embed.description = text
      embed.color = event.server.role(player.tribe.role_id).color if player.tribe
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use `!give CODE` to send your items to other castaways or `!play CODE` to play it yourself.')
    end
  end
end
