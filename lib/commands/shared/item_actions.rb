require 'securerandom'

class Sunny
  def self.pending_item_gives
    @pending_item_gives ||= {}
  end

  def self.pending_item_plays
    @pending_item_plays ||= {}
  end

  def self.item_command_player(event, statuses: ALIVE)
    if event.user.id.host?
      Player.find_by(submissions: event.channel.id, season_id: Setting.season_id, status: statuses) ||
        Player.find_by(confessional: event.channel.id, season_id: Setting.season_id, status: statuses)
    else
      Player.find_by(user_id: event.user.id, season_id: Setting.season_id, status: statuses)
    end
  end

  def self.acknowledge_selection(event, message)
    event.update_message(content: message, components: nil)
  rescue StandardError
    event.channel.send_message(message)
  end

  def self.owned_item_options(player)
    player.items.where(season_id: Setting.season_id).order(:name).first(25).map do |item|
      {
        label: "#{item.code} - #{item.name}"[0, 100],
        value: item.id.to_s,
        description: Array(item.functions).join(', ')[0, 100]
      }
    end
  end

  def self.player_target_options(players)
    players.first(25).map { |target| { label: "#{target.id} - #{target.name}"[0, 100], value: target.id.to_s } }
  end

  def self.item_select_view(token, action, player)
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(
        custom_id: "#{action}_item:#{token}",
        options: owned_item_options(player),
        placeholder: 'Choose an item',
        min_values: 1,
        max_values: 1
      )
    end
    view
  end

  def self.item_target_select_view(token, action, players, placeholder)
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(
        custom_id: "#{action}_target:#{token}",
        options: player_target_options(players),
        placeholder: placeholder,
        min_values: 1,
        max_values: 1
      )
    end
    view
  end

  def self.resolve_player_argument(content, players)
    text = content.to_s.strip
    return nil if text.empty?

    players.find { |player| player.id == text.to_i } ||
      players.find { |player| player.name.downcase == text.downcase } ||
      players.select { |player| player.name.downcase.include?(text.downcase) }.then { |matches| matches.one? ? matches.first : nil }
  end

  def self.give_targets_for(player)
    Player.where(season_id: Setting.season_id, status: ALIVE).where.not(id: player.id).order(:name).to_a
  end

  def self.playable_council_for(item)
    if item.early?
      Council.where(stage: [0], season_id: Setting.season_id).last
    elsif item.now?
      Council.where(stage: [0, 1], season_id: Setting.season_id).last
    elsif item.tallied?
      Council.where(stage: [0, 1, 2], season_id: Setting.season_id).last
    end
  end

  def self.play_item_function(item)
    (Array(item.functions) & (Item::EARLY_FUNCTIONS + Item::NOW_FUNCTIONS + Item::TALLIED_FUNCTIONS)).first
  end

  def self.play_target_candidates(function, player, council, stage = nil)
    case function
    when 'extra_vote'
      vote_targets_for(council, player)
    when 'steal_vote'
      stage == :vote_target ? vote_targets_for(council, player) : vote_targets_for(council, player, require_allowed_vote: true)
    when 'block_vote'
      vote_targets_for(council, player, require_allowed_vote: true)
    when 'idol'
      Vote.where(council_id: council.id).filter_map(&:player).select { |target| target.status == 'In' }
    else
      []
    end
  end

  def self.start_give_flow(event, player, item = nil, target_text = nil)
    unless item
      if owned_item_options(player).empty?
        event.respond("You don't have any items.")
        return
      end

      token = SecureRandom.hex(8)
      pending_item_gives[token] = { user_id: event.user.id, player_id: player.id }
      event.channel.send_message('Which item do you want to give?', false, nil, nil, nil, nil, item_select_view(token, 'give', player))
      return
    end

    targets = give_targets_for(player)
    if targets.empty?
      event.respond('There are no eligible players to give this item to.')
      return
    end

    target = resolve_player_argument(target_text, targets)
    if target.nil?
      token = SecureRandom.hex(8)
      pending_item_gives[token] = { user_id: event.user.id, player_id: player.id, item_id: item.id }
      event.channel.send_message('Who do you want to give it to?', false, nil, nil, nil, nil, item_target_select_view(token, 'give', targets, 'Choose recipient'))
      return
    end

    confirm_give_flow(event, player, item, target)
  end

  def self.confirm_give_flow(event, player, item, target)
    warning = item.targets.empty? ? '' : "\nGiving it away will cancel the current play."
    event.channel.send_message("Give **#{item.name}** to **#{target.name}**?#{warning}\nType `yes` to confirm.")
    confirmation = event.user.await!(timeout: 60)

    unless confirmation && Setting.confirmation?(confirmation.message.content)
      event.channel.send_message('Giving an item cancelled.')
      return
    end

    execute_give_flow(event, { player_id: player.id, item_id: item.id, target_id: target.id })
  end

  def self.execute_give_flow(event, payload)
    player = Player.find_by(id: payload[:player_id], season_id: Setting.season_id)
    item = Item.find_by(id: payload[:item_id], player_id: player&.id, season_id: Setting.season_id)
    target = Player.find_by(id: payload[:target_id], season_id: Setting.season_id, status: ALIVE)
    return event.channel.send_message('Giving an item failed.') unless player && item && target

    unless item.targets.empty?
      cancel_item_play(item)
      record_and_send_event('item_stopped', player: player, item: item)
    end

    item.update(player_id: target.id)
    record_and_send_event("item_given:target=#{target.name}", player: player, item: item)
    record_and_send_event("item_received:from=#{player.name}", player: target, item: item)
    event.channel.send_message("**#{item.name}** now belongs to **#{target.name}**.")
    BOT.channel(target.submissions).send_embed do |embed|
      embed.title = "#{player.name} has sent you an item!"
      embed.description = "**#{item.name}**\n#{item.description}\n**Code:** `#{item.code}`"
    end
  end

  def self.start_play_flow(event, player, item = nil, target_text = nil, second_target_text = nil)
    unless item
      if owned_item_options(player).empty?
        event.respond("You don't have any items.")
        return
      end

      token = SecureRandom.hex(8)
      pending_item_plays[token] = { user_id: event.user.id, player_id: player.id }
      event.channel.send_message('Which item do you want to play?', false, nil, nil, nil, nil, item_select_view(token, 'play', player))
      return
    end

    council = playable_council_for(item)
    unless council
      event.respond("You're not able to play this item now!")
      return
    end

    if item.targets.any?
      confirm_play_flow(event, player, item, action: :cancel, targets: [])
      return
    end

    function = play_item_function(item)
    case function
    when 'safety_without_power'
      confirm_play_flow(event, player, item, action: :play, targets: [])
    when 'extra_vote', 'block_vote', 'idol'
      target = resolve_player_argument(target_text, play_target_candidates(function, player, council))
      return request_play_target(event, player, item, function, :target) unless target

      confirm_play_flow(event, player, item, action: :play, targets: [target.id])
    when 'steal_vote'
      stolen_target = resolve_player_argument(target_text, play_target_candidates(function, player, council, :stolen_target))
      unless stolen_target
        request_play_target(event, player, item, function, :stolen_target)
        return
      end

      vote_target = resolve_player_argument(second_target_text, play_target_candidates(function, player, council, :vote_target))
      unless vote_target
        request_play_target(event, player, item, function, :vote_target, targets: [stolen_target.id])
        return
      end

      confirm_play_flow(event, player, item, action: :play, targets: [stolen_target.id, vote_target.id])
    else
      event.respond('This item does not have a playable function.')
    end
  end

  def self.request_play_target(event, player, item, function, stage, targets: [])
    council = playable_council_for(item)
    candidates = play_target_candidates(function, player, council, stage)
    if candidates.empty?
      event.respond('There are no eligible targets for this item right now.')
      return
    end

    token = SecureRandom.hex(8)
    pending_item_plays[token] = { user_id: event.user.id, player_id: player.id, item_id: item.id, function: function, stage: stage, targets: targets }
    prompt = stage == :vote_target ? 'Choose who receives the vote' : "Choose who to play #{item.name} on"
    event.channel.send_message(prompt, false, nil, nil, nil, nil, item_target_select_view(token, 'play', candidates, prompt))
  end

  def self.confirm_play_flow(event, player, item, action:, targets:)
    names = targets.map { |target_id| Player.find_by(id: target_id)&.name }.compact
    message = if action == :cancel
                "Cancel your current play of **#{item.name}**?"
              elsif names.empty?
                "Play **#{item.name}**?"
              else
                "Play **#{item.name}** involving **#{names.join('**, **')}**?"
              end
    event.channel.send_message("#{message}\nType `yes` to confirm.")
    confirmation = event.user.await!(timeout: 60)

    unless confirmation && Setting.confirmation?(confirmation.message.content)
      event.channel.send_message('Playing an item cancelled.')
      return
    end

    execute_play_flow(event, { player_id: player.id, item_id: item.id, action: action, targets: targets })
  end

  def self.execute_play_flow(event, payload)
    player = Player.find_by(id: payload[:player_id], season_id: Setting.season_id)
    item = Item.find_by(id: payload[:item_id], player_id: player&.id, season_id: Setting.season_id)
    return event.channel.send_message('Playing this item failed.') unless player && item

    if payload[:action] == :cancel
      cancel_item_play(item)
      record_and_send_event('item_stopped', player: player, item: item)
      event.channel.send_message("You've cancelled playing **#{item.name}**.")
      return
    end

    event.channel.send_message("Playing **#{item.name}**...")
    play_item(event, Array(payload[:targets]).map(&:to_s), item, confirmed: true)
  end

  BOT.command :give, description: 'Give an item.' do |event, *args|
    break unless event.user.id.player? || event.user.id.host?

    player = item_command_player(event)
    break unless player

    break unless [player.confessional, player.submissions].include? event.channel.id

    item = args[0] ? player.items.find_by(code: args[0], season_id: Setting.season_id) : nil
    if args[0] && item.nil?
      event.respond("You don't have any item with that code.")
      break
    end

    start_give_flow(event, player, item, args[1..]&.join(' '))
  end

  BOT.command :play, description: 'Plays an item.' do |event, *args|
    break unless event.user.id.player? || event.user.id.host?

    player = item_command_player(event)
    break unless player

    break unless [player.confessional, player.submissions].include? event.channel.id

    item = args[0] ? player.items.find_by(code: args[0], season_id: Setting.season_id) : nil
    if args[0] && item.nil?
      event.respond("You don't have any item with that code.")
      break
    end

    if item && play_item_function(item) == 'steal_vote'
      start_play_flow(event, player, item, args[1], args[2..]&.join(' '))
    else
      start_play_flow(event, player, item, args[1..]&.join(' '))
    end
  end

  BOT.string_select(custom_id: /\Agive_item:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_item_gives[token]
    unless payload && payload[:user_id] == event.user.id
      acknowledge_selection(event, 'This give flow is no longer available.')
      break
    end

    payload[:item_id] = event.values.first.to_i
    player = Player.find_by(id: payload[:player_id], season_id: Setting.season_id)
    item = Item.find_by(id: payload[:item_id], player_id: player&.id, season_id: Setting.season_id)
    unless player && item
      acknowledge_selection(event, 'That item is no longer available.')
      break
    end

    targets = give_targets_for(player)
    if targets.empty?
      acknowledge_selection(event, 'There are no eligible players to give this item to.')
      break
    end

    acknowledge_selection(event, "Selected **#{item.name}** to give.")
    event.channel.send_message('Who do you want to give it to?', false, nil, nil, nil, nil, item_target_select_view(token, 'give', targets, 'Choose recipient'))
  end

  BOT.string_select(custom_id: /\Agive_target:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_item_gives.delete(token)
    unless payload && payload[:user_id] == event.user.id
      acknowledge_selection(event, 'This give flow is no longer available.')
      break
    end

    player = Player.find_by(id: payload[:player_id], season_id: Setting.season_id)
    item = Item.find_by(id: payload[:item_id], player_id: player&.id, season_id: Setting.season_id)
    target = Player.find_by(id: event.values.first.to_i, season_id: Setting.season_id, status: ALIVE)
    unless player && item && target
      acknowledge_selection(event, 'Giving an item failed.')
      break
    end

    acknowledge_selection(event, "Selected **#{target.name}** as the recipient for **#{item.name}**.")
    confirm_give_flow(event, player, item, target)
  end

  BOT.string_select(custom_id: /\Aplay_item:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_item_plays.delete(token)
    unless payload && payload[:user_id] == event.user.id
      acknowledge_selection(event, 'This play flow is no longer available.')
      break
    end

    player = Player.find_by(id: payload[:player_id], season_id: Setting.season_id)
    item = Item.find_by(id: event.values.first.to_i, player_id: player&.id, season_id: Setting.season_id)
    unless player && item
      acknowledge_selection(event, 'That item is no longer available.')
      break
    end

    acknowledge_selection(event, "Selected **#{item.name}** to play.")
    start_play_flow(event, player, item)
  end

  BOT.string_select(custom_id: /\Aplay_target:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_item_plays.delete(token)
    unless payload && payload[:user_id] == event.user.id
      acknowledge_selection(event, 'This play flow is no longer available.')
      break
    end

    player = Player.find_by(id: payload[:player_id], season_id: Setting.season_id)
    item = Item.find_by(id: payload[:item_id], player_id: player&.id, season_id: Setting.season_id)
    target = Player.find_by(id: event.values.first.to_i, season_id: Setting.season_id)
    unless player && item && target
      acknowledge_selection(event, 'Playing this item failed.')
      break
    end

    targets = Array(payload[:targets]) + [target.id]
    selected_for = payload[:stage] == :vote_target ? 'the stolen vote target' : "the target for **#{item.name}**"
    acknowledge_selection(event, "Selected **#{target.name}** as #{selected_for}.")

    if payload[:function] == 'steal_vote' && payload[:stage] == :stolen_target
      request_play_target(event, player, item, payload[:function], :vote_target, targets: targets)
    else
      confirm_play_flow(event, player, item, action: :play, targets: targets)
    end
  end

end
