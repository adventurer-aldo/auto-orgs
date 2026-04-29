class Sunny
  BOT.command :vote, description: 'Vote a castaway for Tribal Council' do |event, *args|
    # ===========================================================================================
    # Once votes are TOTAL_ALLOWED_VOTES == SUBMITTED VOTES, then enter Lock phase.
    # Once you lock, the Bot will make tribal council by itself.
    # It does not mean you can't change votes anymore. It merely means it will start early, unless
    # you need to rethink of something.
    break unless event.user.id.player? || event.user.id.host?

    player = nil

    if event.user.id.host?
      match = Player.where(submissions: event.channel.id, status: ALIVE + ['Jury'])
      break unless match.exists?

      player = match.first

    else
      player = if [0, 1].include? Setting.game_stage
                 Player.find_by(user_id: event.user.id, season_id: Setting.season_id, status: ALIVE)
               else
                 Player.find_by(user_id: event.user.id, season_id: Setting.season_id, status: 'Jury')
               end
    end

    break unless event.channel.id == player.submissions

    vote = Vote.where(player_id: player.id)
    council = Council.where(id: vote.map(&:council), stage: [0,1,3], season_id: Setting.season_id)
    break unless vote.exists? && council.exists?

    council = council.last
    council_votes = council.votes.map(&:votes).flatten
    updater = Vote.where(council_id: council.id).and(vote)
    vote = updater.first

    allowed_votes = vote.allowed
    if allowed_votes <= 0
      event.respond('You do not have any votes!')
    else
      voted = vote.votes
      parchments = vote.parchments
      enemies = vote_targets_for(council, player)

      content = ''
      number = 0
      if allowed_votes > 1 && args[0]
        number = args[0].to_i - 1
        number = 0 if number > allowed_votes - 1 || number.negative?

        content = args[1..]&.join(' ').to_s
      elsif allowed_votes < 2 && args[0]
        content = args.map(&:downcase).join(' ')
      end

      target = nil
      if content == ''
        target = prompt_vote_target(event, player, council, prompt: 'Who would you like to vote?', timeout: 40, targets: enemies)
        event.respond('Timed out! Take your time to decide who you really want to vote.') if target.nil?
        break if target.nil?
        voted[number] = target.id
      end

      target ||= resolve_vote_target(content, enemies)
      if target.nil?
        event.respond("There's no single castaway that matches that.") unless content == ''
        event.respond('Timed out! Take your time to decide who you really want to vote.') if content == ''
        break
      end
      voted[number] = target.id

      if target
        parchments[number] = collect_vote_parchment(event, target, source_event: event)
        updater.update(votes: voted, parchments:)
        record_event('casting_vote', player: player)
        event.respond("You're now voting **#{target.name}**.")
        new_council_votes = council.votes.reload.map(&:votes).flatten
        BOT.channel(council.channel_id).send_message("#{new_council_votes.size - new_council_votes.count(0)}/#{new_council_votes.size}") unless new_council_votes.count(0) == council_votes.count(0)
      else
        'No vote was submitted...'
      end
    end
  end
end
