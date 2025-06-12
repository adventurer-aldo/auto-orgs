class Sunny

  BOT.command :tetest do |event|
    break unless event.user.id.host?
    
    Tribe.all.each do |tribe|
      BOT.channel(tribe.cchannel_id).send_embed do |embed|
        embed.title = '# Immunity Challenge No. 2'
        embed.description = "In your #-submissions channels, write the command `!startmaze`\nYou will be positioned in a 19x10 grid. Your goal is to escape the maze.\nUse the commands:\n\n`!up` - Move up\n`!down` - Move down\n`!left` - Move left\n`!right` - Move right\n\n:green_square: Green squares are traversable squares. \n:red_square: Red squares are walls. \n:white_large_square: Are unknown squares.\n\nFor each movement that you do, you spend a turn.\n**Have each of your team's members find the exit in the least amount of TURNS and win Immunity!**"
      end
    end
  end


  BOT.command :create_dms do |event|
    break unless event.user.id.host?

    Tribe.all.each do |tribe|
      category = event.server.create_channel(tribe.name + ' 1-on-1s', 4)
      players = tribe.players
      players.each_with_index do |player, i|
        ((i + 1)...players.size).each do |j|
          other_player = players[j]
          # Connect player with other_player
          event.respond "#{player.name} connects with #{other_player.name}"
          event.server.create_channel("#{player.name}-#{other_player.name}",
            parent: category,
            topic: tribe.name + "#{player.name} and #{other_player.name} will be chatting privately here, as long as they're on the same tribe!",
            permission_overwrites: [ DENY_EVERY_SPECTATE, Discordrb::Overwrite.new(other_player.user_id, type: 'member', allow: 3072),
            Discordrb::Overwrite.new(player.user_id, type: 'member', allow: 3072)])
        end
      end
    end
  end
  
  BOT.command :misc do |event|
    break #unless event.user.id.host?
    tribes = Tribe.all
    BOT.channel(1382759969044041748).send_message(tribes.map { |tribe|
      players = tribe.players.where(status: ALIVE).select { |player| !['Duke', 'Jack'].include?(player.name)}
      mazes = players.map(&:mazes).map(&:first)
      mazes.delete(nil)
      turns = 0
      mazes.each { |maze| turns += maze.tiles.size }
      "**#{tribe.name}**\nTurns taken: #{turns}\nCastaways within the maze: #{mazes.size}/#{players.size}\nCastaways who reached the end: #{mazes.select { |maze| maze.finished }.size}/#{players.size}"
    }.join("\n\n"))
  end
  
  class TestJob < Que::Job
    self.run_at = proc { Time.now + 60 }

    def run
      enqueue(job_options: { run_at: Time.now + 300})
      tribes = Tribe.all
      BOT.channel(1382759969044041748).load_message(1382818203901890716).edit(tribes.map { |tribe|
        players = tribe.players.where(status: ALIVE).select { |player| !['Duke', 'Jack'].include?(player.name)}
        mazes = players.map(&:mazes).map(&:first)
        mazes.delete(nil)
        turns = 0
        mazes.each { |maze| turns += maze.tiles.size }
        "**#{tribe.name}**\nTurns taken: #{turns}\nCastaways within the maze: #{mazes.size}/#{players.size}\nCastaways who reached the end: #{mazes.select { |maze| maze.finished }.size}/#{players.size}"
      }.join("\n\n"))
      destroy
    end
  end
end