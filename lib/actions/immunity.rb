class Sunny
  BOT.command :transfer_immunity do |event, *args|
    break unless event.user.id.player?

    return event.respond('Immunity can only be transferred after the merge.') unless Setting.game_stage == 1

    council = Council.where(season_id: Setting.season, stage: 0).last
    return event.respond('Immunity is not transferable right now.') if council.nil?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season, status: 'Immune')
    return event.respond("You don't currently have transferable immunity.") if player.nil?
    return event.respond('Use this in your confessional or submissions channel.') unless [player.confessional, player.submissions].include? event.channel.id

    member = event.user.on(event.server)
    return event.respond("You don't currently have the Immunity role.") unless member.role?(Setting.immunity_role_id)

    targets = Player.where(status: ALIVE, season_id: Setting.season).excluding(Player.where(id: player.id))
    content = args.join(' ')
    if content == ''
      event.channel.send_embed do |embed|
        embed.title = 'Who would you like to transfer immunity to?'
        embed.description = targets.map { |target| "**#{target.id}** — #{target.name}" }.join("\n")
        embed.color = event.server.role(player.tribe.role_id).color if player.tribe
      end

      await = event.user.await!(timeout: 60)
      return event.respond('Immunity transfer cancelled.') if await.nil?

      content = await.message.content
    end

    text_attempt = targets.map(&:name).filter { |name| name.downcase.include? content.downcase }
    id_attempt = targets.map(&:id).filter { |id| id == content.to_i }
    target = if text_attempt.size == 1
               Player.find_by(name: text_attempt.first, season_id: Setting.season, status: ALIVE)
             elsif id_attempt.size == 1
               Player.find_by(id: id_attempt.first)
             end

    return event.respond("There's no single castaway that matches that.") if target.nil?

    event.respond("Are you sure you want to transfer immunity to **#{target.name}**?")
    confirmation = event.user.await!(timeout: 60)
    return event.respond('Immunity transfer cancelled.') if confirmation.nil?
    return event.respond('I guess not...') unless CONFIRMATIONS.include? confirmation.message.content.downcase

    player.update(status: 'In')
    target.update(status: 'Immune')
    member.remove_role(Setting.immunity_role_id)
    BOT.user(target.user_id).on(event.server).add_role(Setting.immunity_role_id)
    event.respond("**#{target.name}** now has immunity.")
    BOT.channel(council.channel_id).send_message("**#{player.name}** has transferred immunity to **#{target.name}**.")
  end

  BOT.command :immunity, description: 'Grants immunity to all members of a role and the mentioned users.' do |event|
    break unless event.user.id.host?

    players = []

    unless event.message.mentions.empty?
      event.message.mentions.each do |user|
        players << Player.find_by(user_id: user.id, season_id: Setting.season, status: ALIVE)
      end
    end

    unless event.message.role_mentions.empty?
      event.message.role_mentions.each do |role|
        role.members.each do |member|
          players << Player.find_by(user_id: member.id, season_id: Setting.season, status: ALIVE)
        end
      end
    end

    players.delete(nil)

    players.each do |player|
      next player if player.nil?

      player.update(status: 'Immune')
      BOT.user(player.user_id).on(event.server).add_role(Setting.immunity_role_id)
    end

    if players.empty?
      event.respond('No players were found...')
    else
      event.respond('Immunity was given!')
    end
    return

  end
end
