class Sunny
  DM_CATEGORY_LIMIT = 30

  def self.dm_channel_names(player, other_player)
    ["#{player.name.downcase}-#{other_player.name.downcase}", "#{other_player.name.downcase}-#{player.name.downcase}"]
  end

  def self.find_dm_channel(server, player, other_player)
    server.channels.find { |channel| dm_channel_names(player, other_player).include?(channel.name.to_s.downcase) }
  end

  def self.dm_category(server, base_name)
    categories = server.channels.select { |channel| channel.type == 4 && channel.name.to_s.start_with?(base_name) }
    available = categories.find { |category| server.channels.count { |channel| channel.parent == category } < DM_CATEGORY_LIMIT }
    return available if available

    suffix = categories.size + 1
    name = suffix == 1 ? base_name : "#{base_name} (Part #{suffix})"
    server.create_channel(name, 4)
  end

  def self.unlock_dm_channel(channel, server, player, other_player, message)
    channel.define_overwrite(server.member(player.user_id), 3072, 0)
    channel.define_overwrite(server.member(other_player.user_id), 3072, 0)
    channel.send_message(message)
  end

  def self.create_joint_dms(event)
    Sunny.active_councils.where.not(tribes: []).each do |council|
      players = council.tribes.flat_map { |id| Tribe.find_by(id: id)&.players&.where(status: ALIVE).to_a }.compact
      players.each_with_index do |player, i|
        ((i + 1)...players.size).each do |j|
          other_player = players[j]
          category = dm_category(event.server, 'Joint Tribal 🏝️ 1-on-1s')
          event.respond "#{player.name} connects with #{other_player.name}"
          channel = find_dm_channel(event.server, player, other_player)
          if channel.nil?
            event.server.create_channel("#{player.name}-#{other_player.name}",
              parent: category,
              topic: "#{player.name} and #{other_player.name} will be chatting here for the duration of the Joint Tribal Council!",
              permission_overwrites: [Sunny.deny_every_spectate, Discordrb::Overwrite.new(other_player.user_id, type: 'member', allow: 3072),
              Discordrb::Overwrite.new(player.user_id, type: 'member', allow: 3072)])
          else
            channel.parent = category
            channel.topic = "#{player.name} and #{other_player.name} will be chatting privately here while they participate in the Joint Tribal Council!"
            overwrites = channel.member_overwrites.select { |overwrite| [player.user_id, other_player.user_id].include?(overwrite.id) }
            unlock_dm_channel(channel, event.server, player, other_player, '**Temporarily unlocked** 🔓') if overwrites.map { |overwrite| overwrite.allow.defined_permissions.include?(:send_messages) }.include?(false)
          end
        end
      end
    end
  end

  BOT.command :joint_dms do |event|
    break unless event.user.id.host?

    create_joint_dms(event)
  end

  def self.create_dms(event)
    Setting.tribes.filter_map { |id| Tribe.find_by(id: id) }.each do |tribe|
      category = dm_category(event.server, "#{tribe.name} 1-on-1s")
      category.sort_after(Setting.tribes_category_id)
      index = 0
      players = tribe.players.where(status: ALIVE)
      outsiders = Player.where(status: ALIVE, season_id: Setting.season_id).where.not(tribe_id: tribe.id)
      players.each_with_index do |player, i|
        outsiders.each do |outsider|
          channel = find_dm_channel(event.server, player, outsider)
          next unless channel

          overwrites = channel.member_overwrites.select { |overwrite| [player.user_id, outsider.user_id].include?(overwrite.id) }
          next unless overwrites.map { |overwrite| overwrite.allow.defined_permissions.include?(:send_messages) }.include?(true)

          channel.define_overwrite(event.server.member(player.user_id), 1088, 2048)
          channel.define_overwrite(event.server.member(outsider.user_id), 1088, 2048)
          channel.send_message('**Temporarily locked** 🔒')
        end

        ((i + 1)...players.size).each do |j|
          other_player = players[j]
          category = dm_category(event.server, "#{tribe.name} 1-on-1s") if index > DM_CATEGORY_LIMIT
          index = 0 if index > DM_CATEGORY_LIMIT
          event.respond "#{player.name} connects with #{other_player.name}"
          channel = find_dm_channel(event.server, player, other_player)
          if channel.nil?
            event.server.create_channel("#{player.name}-#{other_player.name}",
              parent: category,
              topic: "#{tribe.name} - #{player.name} and #{other_player.name} will be chatting privately here!",
              permission_overwrites: [Sunny.deny_every_spectate, Discordrb::Overwrite.new(other_player.user_id, type: 'member', allow: 3072),
              Discordrb::Overwrite.new(player.user_id, type: 'member', allow: 3072)])
          else
            channel.parent = category
            channel.topic = "#{tribe.name} - #{player.name} and #{other_player.name} will be chatting privately here!"
            overwrites = channel.member_overwrites.select { |overwrite| [player.user_id, other_player.user_id].include?(overwrite.id) }
            unlock_dm_channel(channel, event.server, player, other_player, '**Permanently unlocked** 🔓') if overwrites.map { |overwrite| overwrite.allow.defined_permissions.include?(:send_messages) }.include?(false)
          end
          index += 1
        end
      end
    end
  end

  BOT.command :create_dms do |event|
    break unless event.user.id.host?

    create_dms(event)
  end

  def self.archive_player_dms(player, server, eliminated: false)
    tribe_player_ids = player.tribe&.players&.where(season_id: Setting.season_id)&.map(&:id) || []
    joint_player_ids = active_councils.select { |council| Array(council.tribes).include?(player.tribe_id) }.flat_map do |council|
      council.tribes.flat_map { |tribe_id| Tribe.find_by(id: tribe_id)&.players&.where(season_id: Setting.season_id)&.map(&:id) }
    end.compact
    close_player_ids = (tribe_player_ids + joint_player_ids).uniq

    Player.where(season_id: Setting.season_id).where.not(id: player.id).find_each do |other_player|
      channel = find_dm_channel(server, player, other_player)
      next unless channel

      [player.user_id, other_player.user_id].each do |user_id|
        member = server.member(user_id)
        channel.define_overwrite(member, 1088, 2048) if member
      end
      channel.parent = Setting.archive_category if Setting.archive_category.to_i.positive?
      leaving_current_chat = eliminated && close_player_ids.include?(other_player.id)
      channel.send_message(leaving_current_chat ? ":broken_heart: **#{player.name} has left the chat...**" : '**Temporarily locked** 🔒')
    end
  end
end
