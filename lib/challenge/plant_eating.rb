class Sunny
  MAZE_WIDTH = 10
  MAZE_HEIGHT = 19
  UNKNOWN = "⬜ "
  WALKABLE = "🟩 "
  WALL = "🟥 "
  CURRENT = "🟧 "
  START = [8, 18] # Based on bottom orange tile
  GOAL = [5, 0]   # Based on top orange tile

  @@maze = [
    [false, false, false, false, false, true, false, false, false, false],
    [false, false, false, false, false, true, true, true, true, false],
    [false, false, false, false, false, false, false, false, true, true],
    [true, true, true, true, true, false, true, true, true, true],
    [true, true, false, false, true, false, true, false, false, false],
    [true, false, false, false, true, true, true, true, true, false],
    [true, false, false, false, true, false, false, false, true, false],
    [true, false, false, false, true, false, false, false, true, false],
    [true, false, true, true, true, true, true, false, true, false],
    [true, false, true, false, false, false, true, false, true, false],
    [true, false, true, false, false, false, true, false, true, false],
    [false, false, true, false, false, false, false, false, false, false],
    [true, true, true, false, true, true, true, true, true, false],
    [true, false, false, false, true, false, false, false, true, false],
    [true, false, false, false, true, false, false, false, true, false],
    [true, false, true, true, true, true, true, true, true, false],
    [true, false, true, false, false, false, false, false, true, false],
    [true, true, true, false, false, false, false, false, true, false],
    [false, false, false, false, false, false, false, false, true, false]
  ]

  @@players = {}

  def self.visible_grid(maze)
    known = maze.tiles.map { |tile| [tile.x, tile.y]}
    px, py = [maze.x, maze.y]
    grid = MAZE_HEIGHT.times.map do |y|
      MAZE_WIDTH.times.map do |x|
        if [x, y] == [px, py]
          CURRENT
        elsif known.include? [x, y]
          @@maze[y][x] ? WALKABLE : WALL
        else
          UNKNOWN
        end
      end
    end
    grid.map { |row| row.join('') }.join("\n")
  end

  def self.reveal(maze, x, y)
    return if x < 0 || x >= MAZE_WIDTH || y < 0 || y >= MAZE_HEIGHT

    maze.tiles.create(x: x, y: y)
    # @@players[player][:known][[x, y]] = true
  end

  def self.try_move(maze, dx, dy, event)
    # user = event.user.id
    # @@players[user] ||= { pos: START.dup, known: { START => true } }
    x, y = [maze.x, maze.y]
    new_x = x + dx
    new_y = y + dy

    maze.update(turns: maze.turns + 1)

    if new_x.between?(0, MAZE_WIDTH - 1) && new_y.between?(0, MAZE_HEIGHT - 1)
      if @@maze[new_y][new_x]
        maze.update(x: new_x, y: new_y)
        reveal(maze, new_x, new_y)
      else
        reveal(maze, new_x, new_y)
      end
    end

    if [new_x, new_y] == [2, 10] # Example event
      event.respond("You hear dangerous footsteps behind you... carnivorous animals are approaching.")
    end

    if [new_x, new_y] == [6, 5] # Example event
      event.respond("You smell a unique herb up ahead. You can turn in the other direction to save time, or you can continue onwards and be a little bit greedy...")
    end

    if [new_x, new_y] == [8, 10] # Example event
      event.respond("You found a rare-looking herb, somewhat half bitten. You can try to savor it, but it could be tasteless.\nUse the command `!escape_vote` to give it a bite.")
    end

    if [new_x, new_y] == GOAL # Example event
      event.respond("You have reached the goal! Congratulations!\nYour total was **#{maze.turns} turns!**")
      maze.update(finished: true)
    end

    event.respond(visible_grid(maze))
  end

  def self.full_maze_view
    @@maze.map do |row|
      row.map { |cell| cell ? WALKABLE : WALL }.join('')
    end.join("\n")
  end

  BOT.command(:startmaze, description: "Start maze game.") do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season)
    break unless player.mazes.size < 1

    maze = player.mazes.create(x: START[0], y: START[1])
    maze.tiles.create(x: START[0], y: START[1])
    # @@players[user] = { pos: START.dup, known: { START => true } }
    event.respond(visible_grid(maze))
  end

  BOT.command(:up) do |e|
    break unless e.user.id.player?

    player = Player.find_by(user_id: e.user.id, season_id: Setting.last.season)

    break unless e.channel.id == player.submissions

    break unless player.mazes.size.positive?

    maze = player.mazes.first

    break if maze.finished

    try_move(maze, 0, -1, e)
  end

  BOT.command(:down) do |e|
    break unless e.user.id.player?

    player = Player.find_by(user_id: e.user.id, season_id: Setting.last.season)

    break unless e.channel.id == player.submissions

    break unless player.mazes.size.positive?

    maze = player.mazes.first

    break if maze.finished

    try_move(maze, 0, 1, e)
  end

  BOT.command(:left) do |e| 
    break unless e.user.id.player?

    player = Player.find_by(user_id: e.user.id, season_id: Setting.last.season)

    break unless e.channel.id == player.submissions

    break unless player.mazes.size.positive?

    maze = player.mazes.first

    break if maze.finished

    try_move(maze, -1, 0, e)
  end

  BOT.command(:right) do |e|
    break unless e.user.id.player?

    player = Player.find_by(user_id: e.user.id, season_id: Setting.last.season)

    break unless e.channel.id == player.submissions

    break unless player.mazes.size.positive?

    maze = player.mazes.first

    break if maze.finished

    try_move(maze, 1, 0, e)
  end

  BOT.command(:master_view, description: "See full maze.") do |event|
    break unless event.user.id.host?

    event.respond(full_maze_view)
  end
end