class Sunny
  BOT.command :stats do |event, *args|
    arguments = player_stat_arguments(event, args)
    requested_season = arguments[:season_id]
    players = player_stat_records(arguments)
    if players == :ambiguous
      event.respond("More than one castaway has a name similar to **#{arguments[:subject]}**. Use a more specific name or mention them.")
      break
    end

    if players.empty?
      event.respond(requested_season ? "**#{arguments[:subject]}** did not star in Season #{requested_season}." : "No Alvivor stats found for **#{arguments[:subject]}**.")
      break
    end

    selected_players = requested_season ? players : players.first(3)
    lines = []
    unless requested_season
      all_players = players
      seasons = all_players.map { |player| Season.find_by(id: player.season_id) }.compact
      played = seasons.map { |season| "#{season.respond_to?(:name) && season.name.to_s.strip != '' ? season.name : 'Unnamed'} (#{season.id})" }
      lines << "Played in seasons: #{played.join(', ')}"
      lines << "Total: #{all_players.size} season#{all_players.size == 1 ? '' : 's'} played"
      lines << "Showing latest #{selected_players.size} season#{selected_players.size == 1 ? '' : 's'}."
      lines << ''
    end

    lines.unshift("**Stats for #{players.first.name}**")
    lines += selected_players.map { |player| player_season_stats_line(player).strip }
    event.respond(lines.join("\n\n"))
  end
end
