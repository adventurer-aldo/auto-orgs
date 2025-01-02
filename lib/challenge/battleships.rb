class Sunny
  GRID_SIZE = 7
  SHIP_SIZES = [1, 2, 3, 4, 5]
  VALID_COLUMNS = ('a'..'g').to_a
  VALID_ROWS = (1..7).to_a.map(&:to_s)
  SHIP_COLORS = { 5 => ':white_large_square:', 4 => ':yellow_square:', 3 => ':orange_square:', 2 => ':purple_square:', 1 => ':green_square:' }

  def self.graphics(id, destroy = false)
    # 1125134304545091584 = Amaranth's role ID
    # 9 = Amaranth's DB ID
    # 10 = Sunchoke's DB ID
    if id == 9 && destroy == false
      'https://i.ibb.co/SXGbKsb/Amaranth-Hit.gif'
    elsif id == 9 && destroy == true
      'https://i.ibb.co/FHTb61C/Amaranths-Destroy.gif'
    elsif id == 10 && destroy == false
      'https://i.ibb.co/XSM0032/Sunchokes-Hit.gif'
    else
      'https://i.ibb.co/W6mLVGs/Sunchokes-Destroy.gif'
    end
  end

  def self.valid_position?(pos)
    !!pos.match(/^[a-jA-J](10|[1-9])$/)
  end

  def self.generate_grid
    grid = Array.new(GRID_SIZE) { Array.new(GRID_SIZE, ':blue_square:') }
    Battleship.all.each do |ship|
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
    event.respond(generate_grid())
  end

  BOT.command :battleships do |event|
    return unless HOSTS.include? event.user.id

    tribes = Setting.last.tribes.map { |tribe_id| Tribe.find_by(id: tribe_id) }
    event.respond("The first tribe to attack will be decided by a coinflip!")
    event.channel.start_typing
    sleep(3)
    event.respond("...")
    event.channel.start_typing
    sleep(3)
    event.respond("First tribe to go will be...")
    event.channel.start_typing
    sleep(3)
    first = tribes.sample
    Turn.create(current_tribe: first.id)
    return "**#{event.server.role(first.role_id).mention}**"
  end

  BOT.command :restartship do |event|
    Battleship.destroy_all
    Damage.destroy_all
    Turn.destroy_all
    return "OK, done."
  end

  BOT.command :placeship do |event, *args|
    return unless Turn.all.empty?

    all_size = Battleship.where(tribe_id: 9).size
    return if all_size >= 5
    size = args.length
    event.respond("That Ship size, (#{size}), is invalid. A Ship must be between 1 and 5 squares wide.") unless SHIP_SIZES.include?(size)
    return unless SHIP_SIZES.include?(size)

    positions = args.map(&:downcase)

    positions.each do |pos|
      event.respond("Invalid position: #{pos}") unless valid_position?(pos)
      return unless valid_position?(pos)
    end

    size_conflict = Battleship.all.map { |ship| ship.squares.size }.include?(args.size)
    event.respond("There's already a Ship with that size!") if size_conflict
    return if size_conflict

    all_occupied_squares = Battleship.all.map { |ship| ship.squares }.flatten
    event.respond("There's already a ship occupying **#{all_occupied_squares.intersection(positions).map(&:upcase).join('**, **')}**") if all_occupied_squares.intersect?(positions)
    return if all_occupied_squares.intersect?(positions)

    rows = positions.map { |pos| pos[1..-1].to_i }.sort
    cols = positions.map { |pos| pos[0].ord }.sort

    if !rows.uniq.one? && !cols.uniq.one?
      event.respond("Ship must be placed in a straight line (horizontal or vertical).")
      return
    end

    if !(rows.each_cons(2).all? { |a, b| b - a == 1 } || cols.each_cons(2).all? { |a, b| b - a == 1 })
      event.respond "Ship positions must be sequential."
      return
    end

    Battleship.create(squares: positions, tribe_id: 9)
    Battleship.create(squares: positions, tribe_id: 10)
    event.respond("Ship placed successfully.\n" + generate_grid())

    event.respond("All ships have been positioned!") if all_size + 1 >= 5
    return
  end

  BOT.command :attack do |event, *args|
    return if Turn.all.empty?

    position = args.join('').downcase
    event.respond("Invalid attack position: #{position}") unless valid_position?(position)
    return unless valid_position?(position)

    player = Tribe.find_by(id: Turn.all.last.current_tribe)
    enemy = Tribe.where.not(id: Turn.all.last.current_tribe).last
    Turn.all.last.update(current_tribe: enemy.id)

    ships = enemy.battleships.all.map { |ship| ship.squares }
    attacks = enemy.damages.all.map { |damage| damage.square }

    event.respond("**#{event.server.role(player.role_id).name}** have decided to attack **#{position.upcase}**...")
    if (ships.flatten - attacks).include? position
      if ((ships.select { |ship| ship.include? position }[0] - [position]) - attacks).empty?
        event.respond(graphics(player.id, true))
        event.respond("**DECISIVE STRIKE!**\n**#{event.server.role(enemy.role_id).name}** had one of their Ships **SINK**!")
      else
        event.respond(graphics(player.id, false))
        event.respond("One of **#{event.server.role(enemy.role_id).name}**'s Ships was hit!")
      end
    elsif (ships.map { |ship| ship.include?(position) && !(ship - attacks).empty? }.include?(true))
      # Hit and it was hit before but not completely gone yet
      event.respond(graphics(player.id, false))
      event.respond("One of **#{event.server.role(enemy.role_id).name}**'s Ships was hit, but the attack didn't do much damage...")
    else
      # Miss!
      event.respond('It was a miss...')
    end

    attacks.push(position)
    enemy.damages.create(square: position)
    if (ships.flatten - attacks).empty?
      Battleship.destroy_all
      Damage.destroy_all
      Turn.destroy_all
      event.respond("All Ships belonging to #{event.server.role(enemy.role_id).name} have sunken...")
      event.channel.start_typing
      sleep(3)
      event.respond("...")
      event.channel.start_typing
      sleep(3)
      event.respond("And as such...")
      event.channel.start_typing
      sleep(3)
      event.respond("**#{event.server.role(enemy.role_id).mention} HAVE WON IMMUNITY!**")
      event.respond("The other hosts will take it from here.")
      return
    end
    event.respond("**Your turn now, #{event.server.role(enemy.role_id).mention()}!**")
    return
  end
end