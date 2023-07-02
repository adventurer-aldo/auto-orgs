class Sunny
  # > Item
  # > Council

  BOT.command :item, description: "Creates a new item to be claimed." do |event, *args|
    break unless HOSTS.include? event.user.id

    event.respond "What is the type?\n**Now | Tallied | Idoled | Super**"
    type = event.user.await!(timeout: 40).message.content.downcase

    event.respond("That's not immediate or queue...") unless %w[n i t s].include? type
    break unless %w[n i t s].include? type

    case type
    when 'n'
      type = 'Now'
    when 't'
      type = 'Tallied'
    when 'i'
      type = 'Idoled'
    when 's'
      type = 'Super'
    end

    event.respond 'What is/are the function codes?'
    functions = event.user.await!(timeout: 40).message.content.downcase.split(' ')

    checked = true
    functions.each do |function|
      checked = false if DEFINED_FUNCTIONS.include?(function) == false
      break if DEFINED_FUNCTIONS.include?(function) == false
    end

    event.respond 'One or more of the submitted functions does not exist!' if checked == false
    break if checked == false

    event.respond("**What's the name?**")
    name = event.user.await!(timeout: 70).message.content

    event.respond("**What's the description?**")
    description = event.user.await!(timeout: 80).message.content

    event.respond('**And lastly, what will be the code?**')
    code = event.user.await!(timeout: 50).message.content.gsub(' ', '_')

    condition = Item.where(code:, season_id: Setting.last.season).exists?

    event.respond('An item with this code already exists!') if condition == true
    break if condition == true

    item = Item.create(code:, name:, description:, timing: type, functions:, season_id: Setting.last.season)
    make_item_commands
    event.respond '**Your item has been created!**'

    event.channel.send_embed do |embed|
      embed.title = item.name
      embed.description = "**Code:** `#{item.code}`\n"
      embed.description << "**Description:** #{item.description}"
    end
  end

  BOT.command :council, description: 'Creates a new Tribal Council channel and sets up everything related to.' do |event|
    break unless HOSTS.include? event.user.id

    event.message.delete
    tribes = event.message.role_mentions
    event.respond('Input at least one tribe!') if tribes.empty?
    break if tribes.empty?

    tribe = []
    confirm = []
    perms = [TRUE_SPECTATE, DENY_EVERY_SPECTATE, PREJURY_SPECTATE]
    cast_left = Player.where(status: ALIVE + ['Exiled'], season_id: Setting.last.season).size
    tribes.each do |tribed|
      if Tribe.where(role_id: tribed.id).exists?
        if Setting.last.tribes.include? Tribe.find_by(role_id: tribed.id, season_id: Setting.last.season).id
          tribe += [Tribe.find_by(role_id: tribed.id).id]
          perms += [Discordrb::Overwrite.new(tribed.id, allow: 3072)]
        else
          confirm << false
        end
      else
        confirm << false
      end
    end

    perms += [JURY_SPECTATE] if Setting.last.game_stage == 1

    event.respond('One or more of those tribes do not exist in the database.') if confirm.include? false
    break if confirm.include? false

    sets = Setting.last
    players = Player.where(tribe: tribe, status: ALIVE, season_id: sets.season)
    channel = event.server.create_channel("f#{cast_left}-#{tribes.map(&:name).join('-')}",
    parent: COUNCILS,
    topic: "F#{cast_left} Tribal Council. Tribes attending: #{tribes.map(&:name).join(', ')}",
    permission_overwrites: perms)

    council = Council.create(tribe_id: tribe, channel_id: channel.id, season_id: sets.season, stage: 1)
    channel.start_typing
    sleep(2)
    BOT.send_message(channel.id, "**Welcome to Tribal Council, #{tribes.map(&:mention).join(' ')}**")
    if sets.game_stage == 1
      BOT.send_file(channel.id, URI.parse('https://i.ibb.co/qD2FKNF/fires.gif').open, filename: 'fires.gif')
      jury = Player.where(status: 'Jury', season_id: sets.season)
      if jury.size.positive?
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
    if Setting.last.game_stage.zero?
      BOT.send_message(channel.id, 'Tonight, one of you castaways will stop receiving resources. And when that happens, you will disappear...')
      channel.start_typing
      sleep(1)
      BOT.send_message(channel.id, 'But you can decide, as a group, which castaway should disappear. For that, you must use the `!vote` command in your submissions channel.')
    else
      BOT.send_message(channel.id, "Tonight, you'll decide who you want to stay in this tribe with you.")
      channel.start_typing
      sleep(1)
      BOT.send_message(channel.id, 'It is ultimately every castaway for itself, but you can decide in unison who you want gone. For that, you must use the `!vote` command in your submissions channel.')
    end
    file = URI.parse(PARCHMENT).open
    BOT.send_file(channel.id, file, filename: 'parchment.png')
    channel.send_embed do |embed|
      embed.title = 'Seedlings attending Tribal Council:'
      embed.description = players.map(&:name).join("\n")
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'You have more or less 24 hours to decide on who to vote!')
      embed.color = tribes.map(&:color).sample
    end
    players.each do |player|
      Vote.create(council_id: council.id, player_id: player.id, parchments: [''])
    end
    channel.start_typing
    sleep(1)
    voters = Vote.where(council_id: council.id).map { |vote| Player.find_by(id: vote.player) }
    immunes = []
    voters.each do |player|
      immunes << player if player.status == 'Immune'
    end
    if immunes.size.positive?
      BOT.send_message(channel.id, "Everyone but **#{immunes.map(&:name).join(', ')}** is fair game.")
    end
    BOT.send_message(channel.id, 'Good luck!')
  end

  BOT.command :ftc, description: 'Begins the Final Tribal Council.' do |event|
    break unless HOSTS.include? event.user.id

    finalists = Player.where(status: ALIVE, season_id: Setting.last.season)
    jury_all = Player.where(status: 'Jury', season_id: Setting.last.season)

    Setting.last.update(game_stage: 2)
    council = Council.create(tribe: [finalists.first.tribe], channel_id: event.server.create_channel(
        'final-tribal-council',
        topic: "The last time we'll read the votes during this season of Maskvivor.",
        parent: FTC,
        permission_overwrites: [DENY_EVERY_SPECTATE, TRUE_SPECTATE]
    ).id, season_id: Setting.last.season)

    finalists.each do |finalist|
      channel = event.server.create_channel("#{finalist.name}-speech",
      topic: "This is where #{finalist.name} will present a case to win the game.",
      parent: FTC,
      permission_overwrites: [EVERY_SPECTATE, Discordrb::Overwrite.new(finalist.user_id, type: 'member', allow: 3072)])
      Vote.create(player_id: finalist.id, council_id: council.id, allowed: 0, votes: [])
      channel.send_message(BOT.user(finalist.user_id).mention.to_s)
    end

    jury_all.each do |jury|
      perms = finalists.map { |finalist| Discordrb::Overwrite.new(finalist.user_id, type: 'member', allow: 3072) }
      perms += [EVERY_SPECTATE, Discordrb::Overwrite.new(jury.user_id, type: 'member', allow: 3072)]
      channel = event.server.create_channel("#{jury.name}-questions",
      topic: "#{jury.name} will be asking questions here, where the finalists will be able to clarify them.",
      parent: FTC,
      permission_overwrites: perms)
      Vote.create(player_id: jury.id, council_id: council.id, allowed: 1, votes: [])
      channel.send_message(BOT.user(jury.user_id).mention.to_s)
    end
    return

  end
end
