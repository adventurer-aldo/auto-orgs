class Sunny
  BOT.command(:set_archive) do |event, *args|
    Setting.archive_category = args
    return "#{BOT.channel(args.join('').to_i).mention} has been set as the **Archive Category!**"
  end
  
BOT.command :snowflake do |event, *args|
    event.respond "Please provide exactly two message IDs." if args.size != 2
    break if args.size != 2

    id1, id2 = args.map(&:to_i)
    begin
      m1 = event.channel.load_message(id1)
      m2 = event.channel.load_message(id2)
      diff = (m1.timestamp - m2.timestamp).abs.to_i
      event.respond "There are #{diff} seconds between the messages."
    rescue
      event.respond "I couldn't find one or both messages. Make sure the IDs are from this channel."
    end
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
