class Sunny

    BOT.command :archive, description: "Sends the current channel to archive and removes talking permissions, while allowing it to be viewed. Add 'all' to archive all channels within the current category." do |event, *args|
        break unless HOSTS.include? event.user.id
        unless args.join(' ') == "all"
            event.respond("**You can't archive this channel!**") if [JURY_SPLITTER,PRE_JURY_SPLITTER].include? event.channel.id
            break if [JURY_SPLITTER,PRE_JURY_SPLITTER,PLAYING_SPLITTER].include? event.channel.id
            event.channel.parent = ARCHIVE
            event.respond ":ballot_box_with_check: **This channel has been archived!**"
            event.channel.permission_overwrites.each do |role, perms|
                if event.server.role(role)
                    unless role == EVERYONE
                        event.channel.define_overwrite(event.server.role(role), 1024, 2048)
                    else
                        event.channel.define_overwrite(event.server.role(role), 0, 3072)
                    end
                elsif event.server.member(role)
                    event.channel.define_overwrite(event.server.member(role), 1024, 2048)
                end
            end
        else
            event.channel.parent.children.each do |channel|
                next channel if [JURY_SPLITTER,PRE_JURY_SPLITTER,PLAYING_SPLITTER].include? channel.id
                channel.parent = ARCHIVE
                BOT.send_message(channel.id, ":ballot_box_with_check: **This channel has been archived!**")
                channel.permission_overwrites.each do |role, perms|
                    if event.server.role(role)
                        unless role == EVERYONE
                            channel.define_overwrite(event.server.role(role), 1024, 2048)
                        else
                            channel.define_overwrite(event.server.role(role), 0, 3072)
                        end
                    elsif event.server.member(role)
                        channel.define_overwrite(event.server.member(role), 1024, 2048)
                    end
                end
            end
        end
        return
    end

    BOT.command :dehive, description: "Delete all channels on the Archives category." do |event|
        break unless HOSTS.include? event.user.id
        if event.channel.parent == ARCHIVE
            return "You cannot do this action while inside the archives."
        else
            BOT.channel(ARCHIVE).children.each(&:delete)
            return "The archives have been deleted."
        end
    end

    BOT.command :add, description: "Adds all mentioned roles to all mentioned members." do |event|
        break unless HOSTS.include? event.user.id
        event.respond("You must mention at least a single user!") if event.message.mentions.size < 1
        break if event.message.mentions.size < 1
        event.respond("You must mention at least a single role!") if event.message.role_mentions.size < 1
        break if event.message.role_mentions.size < 1

        event.message.mentions.each do |user|
            event.message.role_mentions.each do |role|
                user.on(event.server).add_role(role.id)
            end
        end
        return "Task complete."
    end
    
    BOT.command :remove, description: "Removes a role from all its members." do |event|
        break unless HOSTS.include? event.user.id
        event.respond("You have to mention at least one role!") if event.message.role_mentions.size < 1
        break if event.message.role_mentions.size < 1

        event.message.role_mentions.each do |role|
            role.members.each do |member|
                member.remove_role(role.id)
            end
            event.respond("The #{role.mention} role has been removed from all its members.")
        end
        return
    end
    
end