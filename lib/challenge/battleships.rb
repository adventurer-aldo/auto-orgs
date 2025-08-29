class Sunny
  BATTLESHIP_CHANNEL = 1411004604044411044

  GRID_SIZE = 7
  SHIP_SIZES = [1, 2, 3, 4, 5]
  VALID_COLUMNS = ('a'..'g').to_a
  VALID_ROWS = (1..7).to_a.map(&:to_s)
  SHIP_COLORS = { 5 => ':white_large_square:', 4 => ':yellow_square:', 3 => ':orange_square:', 2 => ':purple_square:', 1 => ':green_square:' }

  def self.graphics(id, destroy = false)
    # 1125134304545091584 = Amaranth's role ID
    # 25 = Uada's DB ID 25
    # 26 = Habiti's DB ID 26
    if id == 25 && destroy == false
      'https://i.ibb.co/SXGbKsb/Amaranth-Hit.gif'
    elsif id == 25 && destroy == true
      'https://i.ibb.co/FHTb61C/Amaranths-Destroy.gif'
    elsif id == 26 && destroy == false
      'https://i.ibb.co/XSM0032/Sunchokes-Hit.gif'
    else
      'https://i.ibb.co/W6mLVGs/Sunchokes-Destroy.gif'
    end
  end

  def self.valid_position?(pos)
    !!pos.match(/^[a-gA-G](7|[1-6])$/)
  end

  def self.generate_grid(id)
    grid = Array.new(GRID_SIZE) { Array.new(GRID_SIZE, ':blue_square:') }
    Challenges::Battleships::Ship.where(tribe_id: id).each do |ship|
      color = SHIP_COLORS[ship.squares.size]
      ship.squares.each do |pos|
        col = VALID_COLUMNS.index(pos[0])
        row = pos[1..-1].to_i - 1
        grid[row][col] = color
      end
    end
    grid.map { |row| row.join(' ') }.join("\n")
  end

  BOT.command :grid do |event|
    return unless HOSTS.include? event.user.id

    event.respond(Setting.last.tribes.map { |tribe_id| generate_grid(tribe_id) }.join("\n\n"))
  end

  BOT.command :battleships do |event|
    return unless HOSTS.include? event.user.id

    tribes = Setting.last.tribes.map { |tribe_id| Tribe.find_by(id: tribe_id) }
    event.respond('The first tribe to attack will be decided by a coinflip!')
    event.channel.start_typing
    sleep(3)
    event.respond('...')
    event.channel.start_typing
    sleep(3)
    event.respond('First tribe to go will be...')
    event.channel.start_typing
    sleep(3)
    first = tribes.sample
    Challenges::Battleships::Turn.create(current_tribe: first.id)
    return "**#{event.server.role(first.role_id).mention}**"
  end

  BOT.command :restartship do |event|
    break unless event.user.id.host?

    Challenges::Battleships::Ship.destroy_all
    Challenges::Battleships::Damage.destroy_all
    Challenges::Battleships::Turn.destroy_all
    return "OK, done."
  end

  BOT.command :place_ship do |event, *args|
    break unless event.user.id.player? || event.user.id.host?
    return unless Challenges::Battleships::Turn.all.empty?

    player = Player.find_by(user_id: event.user.id, status: ALIVE)
    tribe = player.tribe
    tribe_ships = Challenges::Battleships::Ship.where(tribe_id: tribe.id)

    return unless event.channel.id == tribe.cchannel_id

    all_size = tribe_ships.size
    return if all_size >= 5

    size = args.length
    event.respond("That Ship size, (#{size}), is invalid. A Ship must be between 1 and 5 squares wide.") unless SHIP_SIZES.include?(size)
    return unless SHIP_SIZES.include?(size)

    positions = args.map(&:downcase)

    positions.each do |pos|
      event.respond("Invalid position: #{pos}") unless valid_position?(pos)
      return unless valid_position?(pos)
    end

    size_conflict = tribe_ships.map { |ship| ship.squares.size }.include?(args.size)
    event.respond("There's already a Ship with that size!") if size_conflict
    return if size_conflict

    all_occupied_squares = tribe_ships.map { |ship| ship.squares }.flatten
    event.respond("There's already a ship occupying **#{all_occupied_squares.intersection(positions).map(&:upcase).join('**, **')}**") if all_occupied_squares.intersect?(positions)
    return if all_occupied_squares.intersect?(positions)

    rows = positions.map { |pos| pos[1..-1].to_i }.sort
    cols = positions.map { |pos| pos[0].ord }.sort

    if !rows.uniq.one? && !cols.uniq.one?
      event.respond('Ship must be placed in a straight line (horizontal or vertical).')
      return
    end

    if !(rows.each_cons(2).all? { |a, b| b - a == 1 } || cols.each_cons(2).all? { |a, b| b - a == 1 })
      event.respond 'Ship positions must be sequential.'
      return
    end

    Challenges::Battleships::Ship.create(squares: positions, tribe_id: tribe.id)
    event.respond("Ship placed successfully.\n" + generate_grid(tribe.id))
    BOT.channel(BATTLESHIP_CHANNEL).send_message("*#{event.server.role(tribe.role_id).name} have placed a ship...*")

    BOT.channel(BATTLESHIP_CHANNEL).send_message("All ships belonging to #{event.server.role(tribe.role_id).name} have been positioned!") if all_size + 1 >= 5
    event.respond("All ships have been positioned!") if all_size + 1 >= 5
    return
  end

  BOT.command :attack do |event, *args|
    return if Challenges::Battleships::Turn.all.empty?

    break unless event.user.id.player? || event.user.id.host?

    position = args.join('').downcase
    event.respond("Invalid attack position: #{position}") unless valid_position?(position)
    return unless valid_position?(position)

    player = Player.find_by(user_id: event.user.id, status: ALIVE).tribe
    enemy = Tribe.where.not(id: player.id).last
    turn = Challenges::Battleships::Turn.all.last

    return unless event.channel.id == player.cchannel_id

    event.respond("Wait! It's not your turn yet!") unless turn.current_tribe == player.id
    return unless turn.current_tribe == player.id

    turn.update(current_tribe: enemy.id)

    ships = enemy.battleships.all.map { |ship| ship.squares }
    attacks = enemy.damages.all.map { |damage| damage.square }

    BOT.channel(BATTLESHIP_CHANNEL).send_message("**#{event.server.role(player.role_id).name}** have decided to attack **#{position.upcase}**...")
    if (ships.flatten - attacks).include? position
      if ((ships.select { |ship| ship.include? position }[0] - [position]) - attacks).empty?
        BOT.channel(BATTLESHIP_CHANNEL).send_message(graphics(player.id, true))
        BOT.channel(BATTLESHIP_CHANNEL).send_message("**CRITICAL HIT!**\n**#{event.server.role(enemy.role_id).name}** had one of their Ships **SINK**!")
      else
        BOT.channel(BATTLESHIP_CHANNEL).send_message(graphics(player.id, false))
        BOT.channel(BATTLESHIP_CHANNEL).send_message("A Ship that belongs to **#{event.server.role(enemy.role_id).name}** was hit!")
      end
    elsif (ships.map { |ship| ship.include?(position) && !(ship - attacks).empty? }.include?(true))
      # Hit and it was hit before but not completely gone yet
      BOT.channel(BATTLESHIP_CHANNEL).send_message(graphics(player.id, false))
      BOT.channel(BATTLESHIP_CHANNEL).send_message("A Ship that belongs to **#{event.server.role(enemy.role_id).name}** was hit, but the attack was ineffective...")
    else
      # Miss!
      BOT.channel(BATTLESHIP_CHANNEL).send_message('It was a miss...')
    end

    attacks.push(position)
    enemy.damages.create(square: position)
    if (ships.flatten - attacks).empty?
      # Challenges::Battleships::Ship.destroy_all
      # Challenges::Battleships::Damage.destroy_all
      # Challenges::Battleships::Turn.destroy_all
      BOT.channel(BATTLESHIP_CHANNEL).send_message("All Ships belonging to #{event.server.role(enemy.role_id).name} have sunken...")
      BOT.channel(BATTLESHIP_CHANNEL).start_typing
      sleep(3)
      BOT.channel(BATTLESHIP_CHANNEL).send_message("...")
      BOT.channel(BATTLESHIP_CHANNEL).start_typing
      sleep(3)
      BOT.channel(BATTLESHIP_CHANNEL).send_message("And as such...")
      BOT.channel(BATTLESHIP_CHANNEL).start_typing
      sleep(3)
      BOT.channel(BATTLESHIP_CHANNEL).send_message("**#{event.server.role(player.role_id).mention} HAVE WON IMMUNITY!**")
      BOT.channel(BATTLESHIP_CHANNEL).send_message("The other hosts will take it from here.")
      return
    end
    BOT.channel(BATTLESHIP_CHANNEL).send_message("**Your turn now, #{event.server.role(enemy.role_id).mention()}!**")
    return
  end
end