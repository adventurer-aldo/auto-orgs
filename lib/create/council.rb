class Sunny
  BOT.command :council, description: 'Creates a new Tribal Council channel and sets up everything related to.' do |event|
    break unless HOSTS.include? event.user.id

    event.message.delete
    tribes = event.message.role_mentions
    event.respond('Input at least one tribe!') if tribes.empty?
    break if tribes.empty?

    tribe = []
    confirm = []
    perms = [TRUE_SPECTATE, DENY_EVERY_SPECTATE, PREJURY_SPECTATE]
    cast_left = Player.where(status: ALIVE + ['Exiled'], season_id: Setting.season).size
    tribes.each do |tribed|
      if Tribe.where(role_id: tribed.id, season_id: Setting.season).exists?
        # Close camps and challenges
        closing_tribe = Tribe.find_by(role_id: tribed.id, season_id: Setting.season)
        BOT.channel(closing_tribe.channel_id).define_overwrite(event.server.role(closing_tribe.role_id), 1088, 2048)
        BOT.channel(closing_tribe.channel_id).send_message("**Closed for Tribal Council.**")
        BOT.channel(closing_tribe.cchannel_id).define_overwrite(event.server.role(closing_tribe.role_id), 1088, 2048)
        BOT.channel(closing_tribe.cchannel_id).send_message("**Closed for Tribal Council.**")
        # Yeah End
        tribe_query = Tribe.where(role_id: tribed.id, season_id: Setting.season).order(id: :desc)&.first&.id
        if Setting.tribes.include? tribe_query
          tribe += [tribe_query]
          perms += [Discordrb::Overwrite.new(tribed.id, allow: 3072)]
        else
          confirm << false
        end
      else
        confirm << false
      end
    end

    perms += [JURY_SPECTATE] if Setting.game_stage == 1

    event.respond('One or more of those tribes do not exist in the database.') if confirm.intersect? [false, nil]
    break if confirm.intersect? [false, nil]

    players = Player.where(tribe_id: tribe, status: ALIVE, season_id: Setting.season_id)
    channel = event.server.create_channel("f#{cast_left}-#{tribes.map(&:name).join('-')}",
    parent: COUNCILS,
    topic: "F#{cast_left} Tribal Council. Tribes attending: #{tribes.map(&:name).join(', ')}",
    permission_overwrites: perms)

    council = Council.create(tribes: tribe, channel_id: channel.id, season_id: Setting.season_id, stage: 1)



    VoteReminderJob.enqueue(council.id, job_options: { run_at: Time.now + (60 * 60 * 22)})
    VoteReminderJob.enqueue(council.id, job_options: { run_at: Time.now + (60 * 60 * 23)})
    VoteReminderJob.enqueue(council.id, job_options: { run_at: Time.now + (60 * 30) + (60 * 60 * 23)})
    VoteReminderJob.enqueue(council.id, job_options: { run_at: Time.now + (60 * 45) + (60 * 60 * 23)})
    VoteReminderJob.enqueue(council.id, job_options: { run_at: Time.now + (60 * 55) + (60 * 60 * 23)})
    channel.start_typing
    sleep(2)
    BOT.send_message(channel.id, "**Welcome to Tribal Council, #{tribes.map(&:mention).join(' ')}**")
    if Setting.game_stage == 1
      BOT.send_file(channel.id, URI.parse('https://i.ibb.co/qD2FKNF/fires.gif').open, filename: 'fires.gif')
      jury = Player.where(status: 'Jury', season_id: Setting.season_id)
      if !jury.empty?
        channel.start_typing
        sleep(2)
        BOT.send_message(channel.id, "**And welcome to the members of our #{event.server.role(JURY).mention}:**")
        channel.start_typing
        sleep(1)
        BOT.send_message(channel.id, "**#{jury.map(&:name).join("\n")}**")
        channel.start_typing
        sleep(1)
        BOT.send_message(channel.id, '...')
      end
    else
      BOT.send_file(channel.id, URI.parse('https://i.ibb.co/TYS4wCd/torches.gif').open, filename: 'torches.gif')
    end
    channel.start_typing
    sleep(1)
    if Setting.game_stage.zero?
      BOT.send_message(channel.id, 'Tonight, one of you castaways will have their torch snuffed out. And when that happens, you will be eliminated from the tribe...')
      channel.start_typing
      sleep(1)
      BOT.send_message(channel.id, 'But you can decide, as a tribe, which castaway should disappear. For that, you must use the `!vote` command in your submissions channel.')
    else
      BOT.send_message(channel.id, "Tonight, you'll decide who you want to stay in this tribe with you, and who you want to eliminate from the game.")
      channel.start_typing
      sleep(1)
      BOT.send_message(channel.id, 'It is ultimately every castaway for itself, but you can decide in unison who you want gone. For that, you must use the `!vote` command in your submissions channel.')
    end
    file = URI.parse(PARCHMENT).open
    BOT.send_file(channel.id, file, filename: 'parchment.png')
    channel.send_embed do |embed|
      embed.title = 'Castaways attending Tribal Council:'
      embed.description = players.map(&:name).join("\n")
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'You have more or less 24 hours to decide on who to vote!')
      embed.color = tribes.map(&:color).sample
    end
    players.each do |player|
      Vote.create(council_id: council.id, player_id: player.id, parchments: ['0'])
      BOT.channel(player.submissions).send_embed do |embed|
        embed.title = "You're participating in the F#{Player.where(status: ALIVE, season_id: Setting.season).size} Tribal Council in #{player.tribe.name}"
        embed.description = "The castaways participating are:\n\n#{players.map(&:name).sort.join("\n")}\n\nUse the `!vote` command to cast your vote!"
        embed.color = tribes.map(&:color).sample
      end
    end
    voters = Vote.where(council_id: council.id).map(&:player)
    immunes = []
    voters.each do |player|
      immunes << player if player.status == 'Immune'
    end
    if immunes.size.positive?
      channel.start_typing
      sleep(1)
      BOT.send_message(channel.id, "Everyone but **#{immunes.map(&:name).join(', ')}** is fair game since they have earned immunity.")
    end
    channel.start_typing
    sleep(1)
    channel.send_message("Votes are due at around <t:#{(Time.now + (60 * 60 * 24)).to_i}:t> tomorrow, but it might be earlier *if* all votes are in before then and everyone agrees.")
    channel.send_message('Good luck!')
    CouncilCountJob.enqueue(council.id)
  end
end