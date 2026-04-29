class Sunny
  def self.active_tribal_councils
    Council.where(season_id: Setting.season_id, stage: Array(0..4))
  end

  def self.cancel_tribal_council(council, server)
    council.tribes.each do |tribe_id|
      tribe = Tribe.find_by(id: tribe_id)
      next unless tribe

      server_role = server.role(tribe.role_id)
      if server_role
        BOT.channel(tribe.channel_id)&.define_overwrite(server_role, 3072, 0)
        BOT.channel(tribe.channel_id)&.send_message('**Tribal Council has been cancelled. Camp is open again.**')
        BOT.channel(tribe.cchannel_id)&.define_overwrite(server_role, 3072, 0)
        BOT.channel(tribe.cchannel_id)&.send_message('**Tribal Council has been cancelled. Challenges are open again.**')
      end
    end

    council.update(stage: 5)
  end

  def self.council_for_tribal_argument(event, content)
    current_channel_council = active_tribal_councils.find_by(channel_id: event.channel.id)
    return current_channel_council if content.empty? && current_channel_council

    role = event.message.role_mentions.first
    tribe = if role
              Tribe.find_by(role_id: role.id, season_id: Setting.season_id)
            else
              Tribe.where(season_id: Setting.season_id).find { |tribe_row| tribe_row.name.downcase == content.downcase }
            end
    return nil unless tribe

    active_tribal_councils.find { |council| Array(council.tribes).include?(tribe.id) }
  end

  BOT.command :cancel_tribal, description: 'Cancels an active Tribal Council.' do |event, *args|
    break unless event.user.id.host?

    content = args.join(' ').strip
    councils = if content.downcase == 'all'
                 active_tribal_councils.to_a
               else
                 council = council_for_tribal_argument(event, content)
                 council ? [council] : []
               end

    if councils.empty?
      event.respond('No active Tribal Council matched that.')
      break
    end

    councils.each { |council| cancel_tribal_council(council, event.server) }
    names = councils.map do |council|
      council.tribes.filter_map { |tribe_id| Tribe.find_by(id: tribe_id)&.name }.join(', ')
    end
    event.respond("Cancelled #{councils.size} Tribal Council#{councils.size == 1 ? '' : 's'}: #{names.join(' | ')}")
  end
end
