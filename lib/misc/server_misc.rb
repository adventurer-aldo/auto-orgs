class Sunny
  BOT.channel(1113177058173005864).children.each do |channel|
    BOT.message_deleted(in: channel) do |event|
      channel.send_message(event.drain.content)
    end
  end

  BOT.command(:set_archive) do |event, *args|
    Setting.last.update(archive_category: args.join(''))
    return "#{BOT.channel(args.join('').to_i).mention} has been set as the **Archive Category!**"
  end

  BOT.command(:removerole, description: 'Removes mentioned role(s) from all members with the role') do |event|
    # Check if the user invoking the command has the necessary permissions
    unless event.user.permission?(:manage_roles)
      event.respond("You don't have permission to manage roles.")
      next
    end

    # Check if roles were mentioned in the command
    unless event.message.role_mentions.any?
      event.respond('Please mention at least one role to remove.')
      next
    end

    # Iterate through each mentioned role
    event.message.role_mentions.each do |role|
      # Remove the role from each member who has it
      event.server.members.each do |member|
        next unless member.roles.include?(role)

        member.remove_role(role)
      end

      event.respond("Role #{role.mention} has been removed from all members.")
    end
    return
  end
end
