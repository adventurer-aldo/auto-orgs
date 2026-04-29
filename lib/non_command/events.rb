class Sunny
  EVENT_SUMMARIES = {
    tribe_buff: '%{player} drew a %{tribe} buff.',
    tribe_immunity: '%{player} earned immunity as part of %{tribe} during the F%{finale}.',
    individual_immunity: '%{player} earned individual immunity during the F%{finale}.',
    item_found: '%{player} found %{item}.',
    item_received: '%{player} received %{item} from %{from}.',
    item_played: '%{player} played %{item}%{details}.',
    item_stopped: '%{player} stopped playing %{item}.',
    casting_vote: '%{player} cast a vote.',
    eliminated: '%{player} was eliminated.',
    item_given: '%{player} gave %{item} to %{target}.'
  }.freeze

  def self.record_event(summary, player: nil, item: nil)
    Event.create(
      summary: summary,
      player_id: player&.id,
      item_id: item&.id
    )
  rescue ActiveRecord::StatementInvalid
    nil
  end

  def self.finale_count
    Player.where(season_id: Setting.season_id, status: ALIVE).size
  end

  def self.event_summary_text(event_row)
    key, payload = event_row.summary.to_s.split(':', 2)
    data = payload.to_s.split('|').each_with_object({}) do |part, memo|
      name, value = part.split('=', 2)
      memo[name.to_sym] = value if name && value
    end

    player = Player.find_by(id: event_row.player_id)&.name || data[:player] || 'A castaway'
    item = Item.find_by(id: event_row.item_id)&.name || data[:item] || 'an item'
    data[:details] ||= ''
    data[:target] ||= 'someone'
    data[:from] ||= 'someone'
    template = EVENT_SUMMARIES[key.to_sym]
    return event_row.summary unless template

    format(template, data.merge(player: player, item: item))
  end

  def self.event_embed_title(event_row)
    key = event_row.summary.to_s.split(':', 2).first.to_sym
    item = Item.find_by(id: event_row.item_id)
    item_type = item&.idol? ? 'Idol' : 'Advantage'

    case key
    when :item_found
      "#{item_type} Found!"
    when :item_received
      "#{item_type} Received!"
    when :item_given
      "#{item_type} Given!"
    when :item_played
      "#{item_type} Played!"
    when :item_stopped
      "#{item_type} Play Cancelled!"
    when :tribe_buff
      'Buff Drawn!'
    when :tribe_immunity
      'Tribal Immunity Won!'
    when :individual_immunity
      'Individual Immunity Won!'
    when :casting_vote
      'Vote Cast!'
    when :eliminated
      'Torch Snuffed!'
    else
      'Something Happened!'
    end
  end

  def self.send_event_embed(event_row)
    return if Setting.events_channel_id.zero?

    BOT.channel(Setting.events_channel_id).send_embed do |embed|
      embed.title = event_embed_title(event_row)
      embed.description = event_summary_text(event_row)
      embed.color = '#CB00FF'
    end
  rescue StandardError
    nil
  end

  def self.record_and_send_event(summary, player: nil, item: nil)
    event_row = record_event(summary, player:, item:)
    send_event_embed(event_row) if event_row
    event_row
  end
end
