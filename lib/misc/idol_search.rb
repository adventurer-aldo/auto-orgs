class Sunny
  # Hardcoded events mapping names to list of coordinates
  EVENTS = {
    treasure: [
      [2, 3], [3, 3], [4, 3],  # B3–D3
    ],
    monster_den: [
      [7, 5], [7, 6], [8, 5], [8, 6],  # G5–H6
    ],
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
      when :treasure
        event.respond("You uncovered the hidden treasure at #{letter.upcase}#{y}! 🏆")
      when :monster_den
        event.respond("You found the monster den at #{letter.upcase}#{y}! 🐉")
      end
    else
      event.respond("Nothing at #{letter.upcase}#{y}.")
    end
  end
end
