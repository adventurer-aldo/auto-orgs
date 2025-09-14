class Sunny
  BOT.command :rename, description: 'Renames an alliance' do |event, *args|
    break unless event.user.id.player? || event.user.id.host?

    if Alliances::Group.where(channel_id: event.channel.id).exists?
      event.channel.name = args.join(' ')
      event.respond("The alliance's name has changed to **#{args.join('-').downcase.gsub(' ', '-').gsub('@', '')}**")
    end
  end

  BOT.command :disband do |event, *args|
    break unless event.user.id.host?

    if Alliances::Group.where(channel_id: event.channel.id).exists?
      Alliances::Group.destroy_by(channel_id: event.channel.id)
      event.respond(":broken_heart: **This alliance has been disbanded...**")
      event.channel.parent = Setting.archive_category
      event.channel.permission_overwrites.each do |role, _perms|
        unless role == EVERYONE || event.server.role(role).nil? == false
          event.channel.define_overwrite(event.server.member(role), 1088, 2048)
        end
      end
    end
  end

  BOT.command :alliance, description: 'Make an alliance with other players on your tribe.' do |event, *args|
    player = event.user.id.host? ? Player.find_by(submissions: event.channel.id, status: ALIVE) : Player.find_by(user_id: event.user.id, season_id: Setting.season, status: ALIVE)
    tribe = player.tribe
    break unless event.user.id.host? || (event.user.id.player? && event.server.role(tribe.role_id).members.size > 3)
    break unless [player.confessional, player.submissions].include? event.channel.id

    enemies = Player.where(tribe_id: [tribe.id] + Council.last.tribes, season_id: Setting.season, status: ALIVE).excluding(Player.where(id: player.id))
    options = enemies.map(&:id)
    options_text = enemies.map(&:name)
    text = enemies.map { |enemy| "**#{enemy.id}** — #{enemy.name}" }

    choices = []
    if args.empty?
      event.channel.send_embed do |embed|
        embed.title = 'Who would you like to make an alliance with?'
        embed.description = text.join("\n")
        embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the numbers for better accuracy.')
        embed.color = event.server.role(tribe.role_id).color
      end
      event.user.await!(timeout: 100) do |await|
        choices = await.message.content.split(' ')
        true
      end
    else
      choices = args
    end

    event.respond 'You did not give me any options...' if choices.empty?
    break if choices.empty?

    choices.map! do |option|
      if option.to_i.zero?
        query = options_text.find { |n| n.downcase.include? option.downcase }
        query.nil? ? nil : options[options_text.index(query)]
      else
        options.find { |n| n == option.to_i }
      end
    end
    choices.compact!
    choices.uniq!

    event.respond('There were no matches.') if choices.empty?
    break if choices.empty?

    event.respond('Not enough members for an alliance!') if choices.size < 2
    break if choices.size < 2

    choices.map! { |choice| Player.find_by(id: choice) }

    event.respond("**You're about to make an alliance with #{choices.map(&:name).join(', ')}. Are you sure?**")
    event.user.await!(timeout: 70) do |await|
      case await.message.content.downcase
      when *%w[yes yeah yeh yuh yup y ye heck\ yeah yep yessir indeed yessey yess]
        rank = Player.where(season_id: Setting.season, status: ALIVE).size
        choices << player
        choices.sort_by!(&:id)

        perms = [TRUE_SPECTATE, DENY_EVERY_SPECTATE]
        choices.each { |n| perms << Discordrb::Overwrite.new(n.user_id, type: 'member', allow: 3072) }

        alliance = Alliances::Group.create!(
          channel_id: event.server.create_channel(
            choices.map(&:name).join('-'),
            parent: ALLIANCES,
            topic: "Created at F#{rank} by **#{player.name}**. | #{choices.map(&:name).join('-')}",
            permission_overwrites: perms
          ).id
        )

        choices.each do |p|
          Alliances::Association.create(alliance_id: alliance.id, player_id: p.id)
        end

        BOT.send_message(alliance.channel_id, event.server.role(tribe.role_id).mention.to_s)
        event.respond("**Your alliance is done! Check out #{BOT.channel(alliance.channel_id).mention}**")
      when *%w[no nah nop nay noo nope nuh nuh-uh]
        event.respond('I guess not...')
      end
    end
    return
  end
end
