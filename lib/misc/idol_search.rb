class Sunny
  # Hardcoded events mapping names to list of coordinates
  EVENTS = {
    hidden_immunity_idol: [
      [7, 1],  # G1
    ],
    extra_vote: [
      [1, 2],  # A2
    ]
  }

  NUM_EMOJIS = %w[1️⃣ 2️⃣ 3️⃣ 4️⃣ 5️⃣ 6️⃣ 7️⃣ 8️⃣ 9️⃣]
  LETTER_EMOJIS = ('a'..'l').map { |ch| ":regional_indicator_#{ch}:" }

  BOT.command :search do |event, *args|
    break unless event.user.id.player?  # only players may search

    coord_str = args.join.delete(' ').downcase
    break event.respond("Invalid coordinate. Use a–l and 1–9.") unless coord_str.match?(/^([a-l])(\d)$/)

    letter, num = coord_str[0], coord_str[1].to_i
    x = letter.ord - 'a'.ord + 1
    y = num

    player = Player.find_by(user_id: event.user.id)

    last_search_time = player.searches.maximum(:last_search_time)
    now = Time.now.to_i
    if last_search_time && now - last_search_time < 43_200
      remaining = 43_200 - (now - last_search_time)
      hours = remaining / 3600
      minutes = (remaining % 3600) / 60
      seconds = remaining % 60
      time_msg = []
      time_msg << "#{hours}h" if hours > 0
      time_msg << "#{minutes}m"
      time_msg << "#{seconds}s"
      break event.respond("It hasn't been 12 hours since your last search! (#{time_msg.join(' ')}) left.")
    end

    if player.searches.exists?(x: x, y: y)
      break event.respond("Already searched #{letter.upcase}#{y}.")
    end

    player.searches.create(x: x, y: y, last_search_time: now)

    # check for event hit
    key, _ = EVENTS.find { |_k, coords| coords.include?([x, y]) } || [nil, nil]
    found = !!key

    # render grid with coordinate labels (1 on top, A–L as emoji)
    header = "⬛" + LETTER_EMOJIS.join
    grid = [header]
    (1..9).each do |row|
      line = NUM_EMOJIS[row - 1]
      (1..12).each do |col|
        if player.searches.exists?(x: col, y: row)
          line += EVENTS.values.any? { |coords| coords.include?([col, row]) } ? '🟩' : '🟥'
        else
          line += '⬜'
        end
      end
      grid << line
    end
    event.respond(grid.join("\n"))

    # outcome
    if found
      case key
      when :hidden_immunity_idol
        event.respond("You found **the** clue! Answer this with a command to earn the item.\n\nHerbivores eat plants to gain energy. But which process do plants use to get that energy?")
      when :extra_vote
        event.respond("Use `jungle` and `king` together to earn your item.")
      end
    else
      event.respond("Nothing at #{letter.upcase}#{y}.")
    end
  end

  BOT.command :heatmap do |event|
  player_searches = Search.all.group(:x, :y).count

  # Generate a 2D array representing frequency
  heatmap = Array.new(9) { Array.new(12, 0) }
  player_searches.each { |(x, y), count| heatmap[y - 1][x - 1] = count }

  max_count = heatmap.flatten.max
  shades = %w[⬜ 🟦 🟩 🟨 🟧 🟥]  # White to red

  color_for = ->(count) {
    return '⬜' if count == 0
    index = [(count * (shades.size - 1) / max_count), shades.size - 1].min
    shades[index]
  }

  header = "⬛" + LETTER_EMOJIS.join
  grid = [header]
  (1..9).each do |row|
    line = NUM_EMOJIS[row - 1]
    (1..12).each do |col|
      line += color_for.call(heatmap[row - 1][col - 1])
    end
    grid << line
  end

  event.respond(grid.join("\n"))
  event.respond("⬜ = 0 searches, 🟦–🟧 = low–medium, 🟥 = most searched")
end

end
