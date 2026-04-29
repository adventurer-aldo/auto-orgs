class Sunny
  def self.ftc_council_for(channel)
    Council.find_by(channel_id: channel.id, season_id: Setting.season_id) ||
      Council.where(season_id: Setting.season_id, stage: [1, 3]).order(:id).last
  end

  def self.ftc_vote_rows(council)
    council.votes.includes(:player).select { |vote| vote.allowed.to_i.positive? }
  end

  def self.ftc_vote_message(voter, target)
    "**#{voter.name}** votes **#{target.name}**."
  end

  def self.ftc_parchment_filename(url)
    url.to_s.downcase.include?('.jpg') || url.to_s.downcase.include?('.jpeg') ? 'parchment.jpg' : 'parchment.png'
  end

  def self.send_ftc_vote_reveal(channel, voter, target, parchment)
    message = ftc_vote_message(voter, target)
    return channel.send_message("#{message} (NO PARCHMENT)") if parchment.to_s.empty? || parchment == '0'

    file = URI.parse(parchment).open
    channel.send_file(file, message, filename: ftc_parchment_filename(parchment))
  rescue ArgumentError
    channel.send_message(message)
    channel.send_file(file, filename: ftc_parchment_filename(parchment)) if file
  rescue StandardError
    channel.send_message("#{message} (NO PARCHMENT)")
  end

  def self.ftc_final_count_message(target_counts)
    lines = target_counts.sort_by { |_target, count| [-count, _target.name] }.map do |target, count|
      "#{count} vote#{count == 1 ? '' : 's'} #{target.name}"
    end

    "**Final Vote Count**\n#{lines.join("\n")}"
  end

  BOT.command :ftc, description: 'Begins the Final Tribal Council.' do |event|
    break unless event.user.id.host?

    finalists = Player.where(status: ALIVE, season_id: Setting.season_id)
    jury_all = Player.where(status: 'Jury', season_id: Setting.season_id)

    Setting.game_stage = 2
    council = Council.create(stage: 1, tribes: [finalists.first.tribe_id], channel_id: event.server.create_channel(
        'final-tribal-council',
        topic: "The last time we'll read the votes during this season of Alvivor.",
        parent: Setting.ftc_category_id,
        permission_overwrites: Sunny.private_spectate_overwrites + (Sunny.debug_mode? ? [] : [Sunny.true_spectate])
    ).id, season_id: Setting.season_id)

    finalists.each do |finalist|
      channel = event.server.create_channel("#{finalist.name}-speech",
      topic: "This is where #{finalist.name} will present a case to win the game.",
      parent: Setting.ftc_category_id,
      permission_overwrites: Sunny.public_spectate_overwrites + [Discordrb::Overwrite.new(finalist.user_id, type: 'member', allow: 3072)])
      Vote.create(player_id: finalist.id, council_id: council.id, allowed: 0, votes: [])
      # channel.send_message('Post your speech to win the game here, ' + BOT.user(finalist.user_id).mention.to_s + '!')
    end

    jury_all.each do |jury|
      perms = Sunny.public_spectate_overwrites
      perms += finalists.map { |finalist| Discordrb::Overwrite.new(finalist.user_id, type: 'member', allow: 3072) }
      perms += [Discordrb::Overwrite.new(jury.user_id, type: 'member', allow: 3072)]
      channel = event.server.create_channel("#{jury.name}-questions",
      topic: "#{jury.name} will be asking questions here, where the finalists will be able to clarify them.",
      parent: Setting.ftc_category_id,
      permission_overwrites: perms)
      Vote.create(player_id: jury.id, council_id: council.id, allowed: 1, parchments: ['0'])
      # channel.send_message(BOT.user(jury.user_id).mention.to_s)

      BOT.channel(jury.submissions).send_embed do |embed|
        embed.title = "As a member of the Jury, **#{jury.name}** has the power to decide the winner of #{season_title}!"
        embed.description = "When the time is right, use the `!vote` command to vote for who you think should win the title of Sole Survivor.\nYour decision matters greatly."
        embed.color = 'df9322'
      end
    end
    return

  end

  BOT.command :ftc_votecount do |event|
    break unless event.user.id.host?

    unless Setting.game_stage == 2
      event.respond('FTC vote count can only happen during Final Tribal Council.')
      break
    end

    council = ftc_council_for(event.channel)
    unless council
      event.respond('No Final Tribal Council vote record was found.')
      break
    end

    vote_reveals = ftc_vote_rows(council).flat_map do |vote|
      Array(vote.votes).each_with_index.filter_map do |target_id, index|
        target = Player.find_by(id: target_id, season_id: Setting.season_id)
        next unless target

        [vote.player, target, Array(vote.parchments)[index]]
      end
    end

    if vote_reveals.empty?
      event.respond('No FTC votes have been submitted yet.')
      break
    end

    target_counts = Hash.new(0)
    vote_reveals.each do |voter, target, parchment|
      send_ftc_vote_reveal(event.channel, voter, target, parchment)
      target_counts[target] += 1
    end

    event.channel.send_message(ftc_final_count_message(target_counts))
    Setting.season.update(end_time: Time.now) if Setting.season&.respond_to?(:end_time)
  end
end
