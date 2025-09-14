class Sunny

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

    tribes = Setting.tribes.map { |id| Tribe.find_by(id: id) }
    tribes.each do |tribe|
      existing_category = event.server.channels.select { |channel| channel.name ==  tribe.name + ' 1-on-1s'}
      category = existing_category.empty? ? event.server.create_channel(tribe.name + ' 1-on-1s', 4) : existing_category.first
      index = 0
      players = tribe.players.where(status: ALIVE)
      outsiders = Player.where(status: ALIVE, season_id: Setting.season).where.not(tribe_id: tribe.id)
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
          category = event.server.create_channel(tribe.name + ' 1-on-1s (Part 2)', 4) if index > 30
          index = 0 if index > 30
          event.respond "#{player.name} connects with #{other_player.name}"
          existing_match = event.server.channels.select { |channel| ["#{player.name.downcase}-#{other_player.name.downcase}", "#{other_player.name.downcase}-#{player.name.downcase}"].include?(channel.name) }
          if existing_match.empty?
            event.server.create_channel("#{player.name}-#{other_player.name}",
              parent: category,
              topic: tribe.name + "#{player.name} and #{other_player.name} will be chatting privately here!",
              permission_overwrites: [ DENY_EVERY_SPECTATE, Discordrb::Overwrite.new(other_player.user_id, type: 'member', allow: 3072),
              Discordrb::Overwrite.new(player.user_id, type: 'member', allow: 3072)])
          else
            chan = existing_match.first
            chan.parent = category
            chan.topic = tribe.name + " - #{player.name} and #{other_player.name} will be chatting privately here!"
            chan_overwrites = chan.member_overwrites.select { |overwrite| [player.user_id, other_player.user_id].include?(overwrite.id) }
            if chan_overwrites.map { |overwrite| overwrite.allow.defined_permissions.include?(:send_messages)  }.include?(false)
              [player.user_id, other_player.user_id].each { |user_id| chan.define_overwrite(event.server.member(user_id), 3072, 0) }
              chan.send_message("**Permanently unlocked** 🔓")
            end
          end
          index += 1
        end
      end
    end
  end

end