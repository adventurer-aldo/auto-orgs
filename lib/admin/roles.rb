class Sunny
  def self.role_ids_from_event(event, args)
    mentioned = event.message.role_mentions.map(&:id)
    typed = args.flat_map { |arg| arg.scan(/\d+/) }.map(&:to_i)
    (mentioned + typed).uniq
  end

  def self.protected_role_references(role_ids)
    tribe_refs = Tribe.where(season_id: Setting.season_id, role_id: role_ids).map { |tribe| [tribe.role_id, "tribe #{tribe.name}"] }
    setting_refs = Setting::INTEGER_SETTINGS.filter_map do |setting_name|
      value = Setting.public_send(setting_name)
      [value, "setting #{setting_name}"] if role_ids.include?(value)
    end

    (tribe_refs + setting_refs).group_by(&:first).transform_values { |refs| refs.map(&:last) }
  end

  BOT.command :add_roles, description: 'Adds all mentioned roles to all mentioned members.' do |event|
    break unless event.user.id.host?

    event.respond('You must mention at least a single user!') if event.message.mentions.empty?
    break if event.message.mentions.empty?

    event.respond('You must mention at least a single role!') if event.message.role_mentions.empty?
    break if event.message.role_mentions.empty?

    event.message.mentions.each do |user|
      event.message.role_mentions.each do |role|
        user.on(event.server).add_role(role.id)
      end
    end
    return 'Task complete.'
  end

  BOT.command :remove_roles, description: 'Removes a role from all its members.' do |event|
    break unless event.user.id.host?

    event.respond('You have to mention at least one role!') if event.message.role_mentions.empty?
    break if event.message.role_mentions.empty?

    event.message.role_mentions.each do |role|
      role.members.each do |member|
        member.remove_role(role.id)
      end
      event.respond("The #{role.mention} role has been removed from all its members.")
    end
    return
  end

  BOT.command :delete_roles, description: 'Deletes roles unless they are used by tribes or settings.' do |event, *args|
    break unless event.user.id.host?

    role_ids = role_ids_from_event(event, args)
    if role_ids.empty?
      event.respond('Mention at least one role or provide one role ID.')
      break
    end

    protected_refs = protected_role_references(role_ids)
    unless protected_refs.empty?
      lines = protected_refs.map do |role_id, refs|
        role = event.server.role(role_id)
        "#{role ? role.mention : role_id} is used by #{refs.join(', ')}"
      end
      event.respond("I won't delete roles that are still configured:\n#{lines.join("\n")}")
      break
    end

    roles = role_ids.filter_map { |role_id| event.server.role(role_id) }
    if roles.empty?
      event.respond("I couldn't find any of those roles in this server.")
      break
    end

    event.respond("Delete #{roles.map(&:mention).join(', ')}? Type `yes` to confirm.")
    confirmation = event.user.await!(timeout: 60)
    unless confirmation && Setting.confirmation?(confirmation.message.content)
      event.respond('Role deletion cancelled.')
      break
    end

    roles.each do |role|
      role.delete
    rescue StandardError => e
      event.respond("Couldn't delete #{role.mention}: #{e.message}")
    end
    event.respond("Deleted #{roles.map(&:mention).join(', ')}.")
  end
end
