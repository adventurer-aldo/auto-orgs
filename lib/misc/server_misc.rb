class Sunny
  BOT.command(:remove_role, description: 'Removes mentioned role(s) from all members with the role') do |event|
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
  end
end

=begin
  BOT.member_join do |event|
    if event.server.id == SERVER_ID
      BOT.send_message(USER_JOIN_CHANNEL, format(Setting.last.join_msg, event.user.name))
      event.user.on(SERVER_ID).add_role(963454509269532752)
    end
  end

  BOT.member_leave do |event|
    BOT.send_message(USER_JOIN_CHANNEL, format(Setting.last.leave_msg, event.user.name)) if event.server.id == SERVER_ID
  end

  BOT.command :set do |event, opera, *args|
    if HOSTS.include? event.user.id
      if opera == 'join'
        Setting.last.update(join_msg: args.join(' '))
        'Your join message has changed!'
      elsif opera == 'leave'
        Setting.last.update(leave_msg: args.join(' '))
        'Your leave message has changed!'
      else
        'There are no operators there.'
      end
    else
      'You do not have permission to use that command.'
    end
  end
=end
