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

    tribes = Setting.last.tribes.map { |id| Tribe.find_by(id: id) }
    
    tribes.each do |tribe|
      BOT.channel(tribe.cchannel_id).send_message("It's time to take greed.")
    end
  end

  BOT.command :greed do |event|
    break # unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id)

    break unless event.channel.id == player.tribe.cchannel_id

    if player.tribe.participants.empty?
      Participant.create(tribe_id: player.tribe.id, player_id: player.id)
      BOT.channel(1383493259644506133).send_message("**#{player.name}** has taken Greed, sending <@#{player.tribe.role_id}> to participate in the Tribal Council...")
      event.respond("#{player.name} took Greed!")
    else
      event.respond("Someone else beat you to it...")
    end
  end

  BOT.command :joint_dms do |event|
    break unless event.user.id.host?

    category = event.server.create_channel('Joint Tribal 🏝️ 1-on-1s', 4)

    players = Council.last.tribes.map { |id| Tribe.find_by(id: id).players.where(status: ALIVE) }.flatten
    players.each_with_index do |player, i|
      ((i + 1)...players.size).each do |j|
        other_player = players[j]
        # Connect player with other_player
        event.respond "#{player.name} connects with #{other_player.name}"
        existing_match = event.server.channels.select { |channel| ["#{player.name.downcase}-#{other_player.name.downcase}", "#{other_player.name.downcase}-#{player.name.downcase}"].include?(channel.name) }
        if existing_match.empty?
          event.server.create_channel("#{player.name}-#{other_player.name}",
            parent: category,
            topic: "#{player.name} and #{other_player.name} will be chatting here for the duration of the Joint Tribal Council!",
            permission_overwrites: [ DENY_EVERY_SPECTATE, Discordrb::Overwrite.new(other_player.user_id, type: 'member', allow: 3072),
            Discordrb::Overwrite.new(player.user_id, type: 'member', allow: 3072)])
        else
          chan = existing_match.first
          chan.parent = category
          chan.topic = "#{player.name} and #{other_player.name} will be chatting privately here while they participate in the Joint Tribal Council!"
          chan_overwrites = chan.member_overwrites.select { |overwrite| [player.user_id, other_player.user_id].include?(overwrite.id) }
          if chan_overwrites.map { |overwrite| overwrite.allow.defined_permissions.include?(:send_messages)  }.include?(false)
            [player.user_id, other_player.user_id].each { |user_id| chan.define_overwrite(event.server.member(user_id), 3072, 0) }
            chan.send_message("**Temporarily unlocked** 🔓")
          end
        end
      end
    end
  end

  BOT.command :create_dms do |event|
    break unless event.user.id.host?

    tribes = Setting.last.tribes.map { |id| Tribe.find_by(id: id) }
    tribes.each do |tribe|
      existing_category = event.server.channels.select { |channel| channel.name ==  tribe.name + ' 1-on-1s'}
      category = existing_category.empty? ? event.server.create_channel(tribe.name + ' 1-on-1s', 4) : existing_category.first
      players = tribe.players.where(status: ALIVE)
      outsiders = Player.where(status: ALIVE).where.not(tribe_id: tribe.id)
      players.each_with_index do |player, i|
        outsiders.each do |outsider|
          existing_match = event.server.channels.select { |channel| ["#{player.name.downcase}-#{outsider.name.downcase}", "#{outsider.name.downcase}-#{player.name.downcase}"].include?(channel.name) }
          if !existing_match.empty?
            chan = existing_match.first
            chan_overwrites = chan.member_overwrites.select { |overwrite| [player.user_id, outsider.user_id].include?(overwrite.id) }
            if chan_overwrites.map { |overwrite| overwrite.allow.defined_permissions.include?(:send_messages)  }.include?(true)
              chan.define_overwrite(event.server.member(player.user_id), 1088, 2048)
              chan.define_overwrite(event.server.member(outsider.user_id), 1088, 2048)
              chan.send_message("**Temporarily locked** 🔒")
            end
          end
        end
        #
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
    self.run_at = proc { Time.now + 6 * 3600 } # 6 hours from now

    def run
      # Call your results reveal/update method
      Sunny.reveal_results_and_update if Individual.where(start_time: nil).exists?

      destroy
    end
  end

end