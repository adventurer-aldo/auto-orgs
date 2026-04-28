class Sunny
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
end
