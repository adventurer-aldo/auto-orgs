class Sunny

    BOT.command :archive, description: "Sends the current channel to archive and removes talking permissions, while allowing it to be viewed. Add 'all' to archive all channels within the current category." do |event, *args|
        unless args.join(' ') == "all"
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
        if event.channel.parent == ARCHIVE
            return "You cannot do this action while inside the archives."
        else
            BOT.channel(ARCHIVE).children.each(&:delete)
            return "The archives have been deleted."
        end
    end
    
end