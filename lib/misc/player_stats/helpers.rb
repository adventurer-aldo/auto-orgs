class Sunny
  CONFESSIONAL_MESSAGE_LIMIT = 10_000

  def self.player_stat_season_name(season)
    return 'Unknown season' unless season

    name = season.respond_to?(:name) && season.name.to_s.strip != '' ? " #{season.name}" : ''
    "Season #{season.id}#{name}"
  end

  def self.player_stat_arguments(event, args)
    season_id = args.find { |arg| arg.to_s.match?(/\A\d+\z/) && arg.to_i.positive? }&.to_i
    mention = event.message.mentions.first
    name_query = args.reject { |arg| arg.to_s.match?(/\A\d+\z/) || arg.to_s.match?(/\A<@!?\d+>\z/) }.join(' ').strip

    if mention
      { season_id: season_id, user_id: mention.id, subject: mention.respond_to?(:display_name) ? mention.display_name : mention.username }
    elsif name_query.empty?
      { season_id: season_id, user_id: event.user.id, subject: event.user.respond_to?(:display_name) ? event.user.display_name : event.user.username }
    else
      { season_id: season_id, name_query: name_query, subject: name_query }
    end
  end

  def self.player_stat_records(arguments)
    if arguments[:user_id]
      scope = Player.where(user_id: arguments[:user_id])
      scope = scope.where(season_id: arguments[:season_id]) if arguments[:season_id]
      return scope.order(season_id: :desc).to_a
    end

    scope = Player.all
    scope = scope.where(season_id: arguments[:season_id]) if arguments[:season_id]
    query = arguments[:name_query].to_s.downcase
    matches = scope.select { |player| player.name.downcase.include?(query) }
    exact_matches = matches.select { |player| player.name.downcase == query }
    matches = exact_matches unless exact_matches.empty?
    matched_names = matches.map { |player| player.name.downcase }.uniq
    return :ambiguous if matched_names.size > 1

    matches.sort_by { |player| -player.season_id.to_i }
  end

  def self.confessional_activity(player)
    channel = BOT.channel(player.confessional)
    return { missing: true, messages: 0, words: 0 } unless channel

    before_id = nil
    scanned_messages = 0
    total_messages = 0
    total_words = 0

    loop do
      batch = before_id ? channel.history(100, before_id) : channel.history(100)
      break if batch.empty?

      batch.each do |message|
        scanned_messages += 1
        next unless message.author&.id == player.user_id

        total_messages += 1
        total_words += message.content.to_s.scan(/\S+/).size
      end

      before_id = batch.last.id
      break if batch.size < 100 || scanned_messages >= CONFESSIONAL_MESSAGE_LIMIT
    end

    { missing: false, messages: total_messages, words: total_words, capped: scanned_messages >= CONFESSIONAL_MESSAGE_LIMIT }
  rescue StandardError
    { missing: true, messages: 0, words: 0 }
  end

  def self.item_event_ids(player, keys)
    Event.where(player_id: player.id).select do |event_row|
      keys.include?(event_row.summary.to_s.split(':', 2).first)
    end.map(&:item_id).compact
  end

  def self.item_stats_for(player)
    found_ids = item_event_ids(player, %w[item_found])
    received_ids = item_event_ids(player, %w[item_received])
    played_ids = item_event_ids(player, %w[item_played])
    current_ids = Item.where(season_id: player.season_id, player_id: player.id).map(&:id)
    had_ids = (found_ids + received_ids + current_ids).uniq
    fallback_played_ids = Item.where(id: had_ids).select do |item|
      item.has_attribute?('played') ? item.played : !Array(item.targets).empty?
    end.map(&:id)
    played_ids = (played_ids + fallback_played_ids).uniq

    {
      had: had_ids.size,
      found: found_ids.uniq.size,
      received: received_ids.uniq.size,
      played: played_ids.size,
      unplayed: [had_ids.size - played_ids.size, 0].max
    }
  end

  def self.player_season_stats_line(player)
    season = Season.find_by(id: player.season_id)
    activity = confessional_activity(player)
    item_stats = item_stats_for(player)
    rank = player.rank ? ordinal(player.rank) : 'Unranked'
    tribal_count = Vote.joins(:council).where(player_id: player.id, councils: { season_id: player.season_id }).count
    confessional = if activity[:missing]
                     'Confessional: channel not found'
                   else
                     "Confessional: #{activity[:messages]} messages, #{activity[:words]} words#{activity[:capped] ? ' (first 10,000 messages scanned)' : ''}"
                   end

    <<~TEXT
      **#{player_stat_season_name(season)}**
      Rank: #{rank}
      Tribal Councils attended: #{tribal_count}
      Items had: #{item_stats[:had]} (found #{item_stats[:found]}, received #{item_stats[:received]}, played #{item_stats[:played]}, unplayed #{item_stats[:unplayed]})
      #{confessional}
    TEXT
  end
end
