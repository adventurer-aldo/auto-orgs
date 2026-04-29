require 'securerandom'

class Sunny
  def self.pending_vote_targets
    @pending_vote_targets ||= {}
  end

  def self.vote_target_options(targets)
    targets.first(25).map do |target|
      {
        label: "#{target.id} - #{target.name}"[0, 100],
        value: target.id.to_s
      }
    end
  end

  def self.vote_target_select_view(token, targets)
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(
        custom_id: "vote_target:#{token}",
        options: vote_target_options(targets),
        placeholder: 'Choose who to vote',
        min_values: 1,
        max_values: 1
      )
    end
    view
  end

  def self.acknowledge_selection(event, message)
    event.update_message(content: message, components: nil)
  rescue StandardError
    event.channel.send_message(message)
  end

  def self.vote_command_player(event)
    if event.user.id.host?
      Player.where(submissions: event.channel.id, status: ALIVE + ['Jury']).first
    elsif [0, 1].include? Setting.game_stage
      Player.find_by(user_id: event.user.id, season_id: Setting.season_id, status: ALIVE)
    else
      Player.find_by(user_id: event.user.id, season_id: Setting.season_id, status: 'Jury')
    end
  end

  def self.active_vote_context(event)
    player = vote_command_player(event)
    return nil unless player && event.channel.id == player.submissions

    vote_scope = Vote.where(player_id: player.id)
    council = Council.where(id: vote_scope.map(&:council), stage: [0, 1, 3], season_id: Setting.season_id).last
    return nil unless vote_scope.exists? && council

    vote_record = Vote.where(council_id: council.id).and(vote_scope).first
    return nil unless vote_record

    [player, council, vote_record]
  end

  def self.vote_argument_parts(args, allowed_votes)
    number = 0
    content = ''

    if allowed_votes > 1 && args[0]
      number = args[0].to_i - 1
      number = 0 if number > allowed_votes - 1 || number.negative?
      content = args[1..]&.join(' ').to_s
    elsif allowed_votes < 2 && args[0]
      content = args.map(&:downcase).join(' ')
    end

    [number, content]
  end

  def self.submit_vote_target(event, player, council, vote_record, number, target, source_event: nil)
    council_votes = council.votes.map(&:votes).flatten
    voted = Array(vote_record.votes)
    parchments = Array(vote_record.parchments)
    voted[number] = target.id
    parchments[number] = collect_vote_parchment(event, target, source_event: source_event)
    vote_record.update(votes: voted, parchments:)
    record_event('casting_vote', player: player)
    respond_to_event(event, "You're now voting **#{target.name}**.")
    new_council_votes = council.votes.reload.map(&:votes).flatten
    BOT.channel(council.channel_id).send_message("#{new_council_votes.size - new_council_votes.count(0)}/#{new_council_votes.size}") unless new_council_votes.count(0) == council_votes.count(0)
  end

  BOT.command :vote, description: 'Vote a castaway for Tribal Council' do |event, *args|
    # ===========================================================================================
    # Once votes are TOTAL_ALLOWED_VOTES == SUBMITTED VOTES, then enter Lock phase.
    # Once you lock, the Bot will make tribal council by itself.
    # It does not mean you can't change votes anymore. It merely means it will start early, unless
    # you need to rethink of something.
    break unless event.user.id.player? || event.user.id.host?

    context = active_vote_context(event)
    break unless context

    player, council, vote = context

    allowed_votes = vote.allowed
    if allowed_votes <= 0
      event.respond('You do not have any votes!')
    else
      voted = vote.votes
      parchments = vote.parchments
      enemies = vote_targets_for(council, player)

      number, content = vote_argument_parts(args, allowed_votes)

      target = nil
      if content == ''
        if enemies.empty?
          event.respond('There are no eligible vote targets.')
          break
        end

        token = SecureRandom.hex(8)
        pending_vote_targets[token] = { user_id: event.user.id, player_id: player.id, council_id: council.id, vote_id: vote.id, number: number }
        event.channel.send_message('Who would you like to vote?', false, nil, nil, nil, nil, vote_target_select_view(token, enemies))
        break
      end

      target ||= resolve_vote_target(content, enemies)
      if target.nil?
        event.respond("There's no single castaway that matches that.") unless content == ''
        event.respond('Timed out! Take your time to decide who you really want to vote.') if content == ''
        break
      end

      if target
        submit_vote_target(event, player, council, vote, number, target, source_event: event)
      else
        'No vote was submitted...'
      end
    end
  end

  BOT.string_select(custom_id: /\Avote_target:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_vote_targets.delete(token)

    if payload.nil? || payload[:user_id] != event.user.id
      event.respond(content: 'This vote selection is no longer available.', ephemeral: true)
      break
    end

    player = Player.find_by(id: payload[:player_id], season_id: Setting.season_id)
    council = Council.find_by(id: payload[:council_id], season_id: Setting.season_id)
    vote_record = Vote.find_by(id: payload[:vote_id], council_id: council&.id, player_id: player&.id)
    target = Player.find_by(id: event.values.first.to_i, season_id: Setting.season_id)

    unless player && council && vote_record && target
      acknowledge_selection(event, 'This vote can no longer be submitted.')
      break
    end

    acknowledge_selection(event, "Selected **#{target.name}** as your vote target.")
    submit_vote_target(event, player, council, vote_record, payload[:number], target)
  end
end
