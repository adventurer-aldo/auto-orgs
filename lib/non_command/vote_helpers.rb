class Sunny
  def self.vote_targets_for(council, player, require_allowed_vote: false)
    vote_scope = Vote.where(council_id: council.id)
    vote_scope = vote_scope.excluding(Vote.where(player_id: player.id)) if player
    vote_scope = vote_scope.where(allowed: Array(1..10)) if require_allowed_vote

    vote_scope.filter_map(&:player).select { |target| target.status == 'In' }
  end

  def self.resolve_vote_target(content, targets)
    text = content.to_s.downcase
    text_attempt = targets.map(&:name).filter { |name| name.downcase.include? text }
    id_attempt = targets.map(&:id).filter { |id| id == text.to_i }

    return targets.find { |target| target.name == text_attempt.first } if text_attempt.size == 1
    return targets.find { |target| target.id == id_attempt.first } if id_attempt.size == 1

    nil
  end

  def self.prompt_vote_target(event, player, council, prompt:, timeout: 80, targets: nil)
    targets ||= vote_targets_for(council, player)

    event.channel.send_embed do |embed|
      embed.title = prompt
      embed.description = targets.map { |target| "**#{target.id}** - #{target.name}" }.join("\n")
      embed.color = event.server.role(player.tribe.role_id).color if player&.tribe
    end

    await = event.user.await!(timeout: timeout)
    event.respond("You didn't pick a target...") if await.nil?
    return nil if await.nil?

    target = resolve_vote_target(await.message.content, targets)
    event.respond("There's no single castaway that matches that.") if target.nil? && await.message.content != ''
    target
  end

  def self.parchment_from_message(message)
    unless message.attachments.empty?
      url = message.attachments.first.url
      return url if url =~ /.*\.[pj][np]g/
    end

    message.content[/https:\/\/cdn\.discordapp\.com\/attachments.*\.[pj][np]g/] ||
      message.content[/https:\/\/media\.discordapp\.net\/attachments.*\.[pj][np]g/]
  end

  def self.collect_vote_parchment(event, target, source_event: nil)
    source_parchment = parchment_from_message(source_event.message) if source_event
    if source_parchment
      event.respond('**Got your parchment!**')
      return source_parchment
    end

    event.respond('Time to upload a parchment! Right in your next message!')
    file = URI.parse(Setting.parchment_url).open
    BOT.send_file(event.channel, file, filename: 'parchment.png')
    image = event.user.await!(timeout: 600)

    parchment = parchment_from_message(image.message) if image
    if parchment
      event.respond('**Got your parchment!**')
      return parchment
    end

    event.respond "I couldn't find a parchment there... Guess I'll make one for you."
    source_message = event.channel.send_file generate_parchment(target.name)
    source_message.attachments.first&.url || '0'
  end
end
