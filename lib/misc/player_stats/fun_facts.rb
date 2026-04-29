class Sunny
  def self.top_player_name(player_id)
    Player.find_by(id: player_id)&.name || "Player #{player_id}"
  end

  def self.item_found_rank(player_ids, selected_player_ids)
    found_counts = Hash.new(0)
    Event.where(player_id: player_ids).select { |event_row| event_row.summary.to_s.start_with?('item_found') }.each do |event_row|
      found_counts[event_row.player_id] += 1
    end
    total_found = selected_player_ids.sum { |player_id| found_counts[player_id].to_i }
    ranked_counts = found_counts.values.uniq.sort.reverse
    rank = ranked_counts.index(total_found)&.+(1)
    [total_found, rank]
  end

  def self.fun_fact_stats(players)
    season_ids = players.map(&:season_id)
    selected_player_ids = players.map(&:id)
    season_player_ids = Player.where(season_id: season_ids).map(&:id)
    my_votes = Vote.joins(:council).where(player_id: selected_player_ids, councils: { season_id: season_ids }).to_a
    council_ids = my_votes.map(&:council_id).uniq
    other_votes = Vote.where(council_id: council_ids).where.not(player_id: selected_player_ids).to_a

    same_vote_counts = Hash.new(0)
    my_votes.each do |vote|
      targets = Array(vote.votes).reject(&:zero?)
      other_votes.select { |other_vote| other_vote.council_id == vote.council_id }.each do |other_vote|
        same_vote_counts[other_vote.player_id] += (targets & Array(other_vote.votes).reject(&:zero?)).size
      end
    end

    attended_counts = Hash.new(0)
    other_votes.each { |vote| attended_counts[vote.player_id] += 1 }
    received_from_player = Hash.new(0)
    my_votes.each do |vote|
      Array(vote.votes).reject(&:zero?).each { |target_id| received_from_player[target_id] += 1 }
    end

    found_total, found_rank = item_found_rank(season_player_ids, selected_player_ids)

    {
      same_vote: same_vote_counts.max_by { |_player_id, count| count },
      attended: attended_counts.max_by { |_player_id, count| count },
      received: received_from_player.max_by { |_player_id, count| count },
      found_total: found_total,
      found_rank: found_rank,
      recorded_idol_plays: Event.where(player_id: selected_player_ids).select do |event_row|
        next false unless event_row.summary.to_s.start_with?('item_played')

        Item.find_by(id: event_row.item_id)&.idol?
      end.count
    }
  end

  BOT.command :fun_facts do |event, *args|
    arguments = player_stat_arguments(event, args)
    requested_season = arguments[:season_id]
    players = player_stat_records(arguments)
    if players == :ambiguous
      event.respond("More than one castaway has a name similar to **#{arguments[:subject]}**. Use a more specific name or mention them.")
      break
    end

    if players.empty?
      event.respond(requested_season ? "**#{arguments[:subject]}** did not star in Season #{requested_season}." : "No Alvivor fun facts found for **#{arguments[:subject]}**.")
      break
    end

    selected_players = requested_season ? players : players.first(3)
    stats = fun_fact_stats(selected_players)
    scope = requested_season ? "Season #{requested_season}" : "latest #{selected_players.size} season#{selected_players.size == 1 ? '' : 's'}"

    lines = ["**Fun facts for #{players.first.name} in #{scope}:**"]
    if stats[:same_vote]
      lines << "Most often voted with: #{top_player_name(stats[:same_vote][0])} (#{stats[:same_vote][1]} matching vote#{stats[:same_vote][1] == 1 ? '' : 's'})"
    else
      lines << 'Most often voted with: not enough vote data'
    end

    if stats[:attended]
      lines << "Most Tribal Councils attended with: #{top_player_name(stats[:attended][0])} (#{stats[:attended][1]})"
    else
      lines << 'Most Tribal Councils attended with: not enough council data'
    end

    if stats[:received]
      lines << "Received the most votes from you: #{top_player_name(stats[:received][0])} (#{stats[:received][1]})"
    else
      lines << 'Received the most votes from you: no recorded votes'
    end

    rank_text = stats[:found_rank] ? "rank ##{stats[:found_rank]} among players in scope" : 'unranked'
    lines << "Items found: #{stats[:found_total]} (#{rank_text})"
    lines << "Recorded idol plays: #{stats[:recorded_idol_plays]}"

    event.respond(lines.join("\n"))
  end
end
