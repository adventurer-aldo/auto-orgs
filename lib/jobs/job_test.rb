class Sunny

  BOT.command :tetest do |event|
    break unless event.user.id.host?
    
    Tribe.all.each do |tribe|
      BOT.channel(tribe.cchannel_id).send_embed do |embed|
        embed.title = '# Immunity Challenge No. 3'
        embed.description = "In this channel, and once I, **Sunny** send the message \"It's time to take greed.\"...\nUse the command `!greed` to send your participate in the Tribal Council, while earning **Individual Immunity** just for yourself within your tribe."
      end
    end
  end

  BOT.command :gogreed do |event|
    break unless event.user.id.host?
    
    BOT.channel(1383493259644506133).send_message("It's time to take greed.")
  end

  BOT.command :greed do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.tribe.cchannel_id

    if player.tribe.participants.empty?
      Participant.create(tribe_id: player.tribe.id, player_id: player.id)
      BOT.channel(1383493259644506133).send_message("**#{player.name}** has taken Greed, sending <@#{player.tribe.role_id}> to participate in the Tribal Council...")
    else
      event.respond("Someone else beat you to it...")
    end
  end

  BOT.command :create_dms do |event|
    break unless event.user.id.host?

    tribes = Setting.last.tribes.map { |id| Tribe.find_by(id: id) }
    tribes.each do |tribe|
      existing_category = event.server.channels.select { |channel| channel.name ==  tribe.name + ' 1-on-1s'}
      category = existing_category.empty? ? event.server.create_channel(tribe.name + ' 1-on-1s', 4) : existing_category.first
      players = tribe.players
      players.each_with_index do |player, i|
        ((i + 1)...players.size).each do |j|
          other_player = players[j]
          # Connect player with other_player
          event.respond "#{player.name} connects with #{other_player.name}"
          existing_match = event.server.channels.select { |channel| ["#{player.name.downcase}-#{other_player.name.downcase}", "#{other_player.name.downcase}-#{player.name.downcase}"].include?(channel.name) }
          if existing_match.empty?
            event.server.create_channel("#{player.name}-#{other_player.name}",
              parent: category,
              topic: tribe.name + "#{player.name} and #{other_player.name} will be chatting privately here, as long as they're on the same tribe!",
              permission_overwrites: [ DENY_EVERY_SPECTATE, Discordrb::Overwrite.new(other_player.user_id, type: 'member', allow: 3072),
              Discordrb::Overwrite.new(player.user_id, type: 'member', allow: 3072)])
          else
            chan = existing_match.first
            chan.parent = category
            chan.topic = tribe.name + "#{player.name} and #{other_player.name} will be chatting privately here, as long as they're on the same tribe!"
          end
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
      TestJob.enqueue(job_options: { run_at: Time.now + 300})
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