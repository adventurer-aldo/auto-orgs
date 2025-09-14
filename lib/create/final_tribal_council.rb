class Sunny
  BOT.command :ftc, description: 'Begins the Final Tribal Council.' do |event|
    break unless HOSTS.include? event.user.id

    finalists = Player.where(status: ALIVE, season_id: Setting.season)
    jury_all = Player.where(status: 'Jury', season_id: Setting.season)

    Setting.last.update(game_stage: 2)
    council = Council.create(stage: 1, tribes: [finalists.first.tribe_id], channel_id: event.server.create_channel(
        'final-tribal-council',
        topic: "The last time we'll read the votes during this season of Alvivor.",
        parent: FTC,
        permission_overwrites: [DENY_EVERY_SPECTATE, TRUE_SPECTATE]
    ).id, season_id: Setting.season)

    finalists.each do |finalist|
      channel = event.server.create_channel("#{finalist.name}-speech",
      topic: "This is where #{finalist.name} will present a case to win the game.",
      parent: FTC,
      permission_overwrites: [EVERY_SPECTATE, Discordrb::Overwrite.new(finalist.user_id, type: 'member', allow: 3072)])
      Vote.create(player_id: finalist.id, council_id: council.id, allowed: 0, votes: [])
      # channel.send_message('Post your speech to win the game here, ' + BOT.user(finalist.user_id).mention.to_s + '!')
    end

    jury_all.each do |jury|
      perms = finalists.map { |finalist| Discordrb::Overwrite.new(finalist.user_id, type: 'member', allow: 3072) }
      perms += [EVERY_SPECTATE, Discordrb::Overwrite.new(jury.user_id, type: 'member', allow: 3072)]
      channel = event.server.create_channel("#{jury.name}-questions",
      topic: "#{jury.name} will be asking questions here, where the finalists will be able to clarify them.",
      parent: FTC,
      permission_overwrites: perms)
      Vote.create(player_id: jury.id, council_id: council.id, allowed: 1, parchments: ['0'])
      # channel.send_message(BOT.user(jury.user_id).mention.to_s)

      BOT.channel(jury.submissions).send_embed do |embed|
        embed.title = "As a member of the Jury, **#{jury.name}** has the power to decide the winner of Alvivor Season 3: Spirits & Souls!"
        embed.description = "When the time is right, use the `!vote` command to vote for who you think should win the title of Sole Survivor.\nYour decision matters greatly."
        embed.color = 'df9322'
      end
    end
    return

  end
end