class Sunny
    # > Item
    # > Council

    BOT.command :item do |event, *args|
        return "Not implemented yet."
    end

    BOT.command :council do |event|
            if HOSTS.include? event.user.id
            tribes = event.message.role_mentions
            event.respond("Input at least one tribe!") if tribes.size < 1
            break if tribes.size < 1


            @tribe = []
            @confirm = []
            @perms = [TRUE_SPECTATE, DENY_EVERY]
            @cast_left = Player.where(status: ["In","Exiled"], season: Setting.last.season).size
            tribes.each do |tribe|
                unless Tribe.where(role_id: tribe.id).exists?
                    @confirm << false
                else
                    @tribe += [Tribe.find_by(role_id: tribe.id).id]
                    @perms += [Discordrb::Overwrite.new(tribe.id, allow: 3072)]
                end
            end

            if @confirm.include? false
                event.respond "One or more of those tribes do not exist in the database."
                    return
            else
                sets = Setting.last
                players = Player.where(tribe: @tribe, status: "In", season: sets.season)
                channel = event.server.create_channel("f#{@cast_left}-#{tribes.map(&:name).join('-')}",
                parent: COUNCILS,
                topic: "F#{@cast_left} Tribal Council. Tribes attending: #{tribes.map(&:name).join(', ')}",
                permission_overwrites: @perms)

                council = Council.create(tribe: @tribe, channel_id: channel.id)
                channel.start_typing
                sleep(2)
                BOT.send_message(channel.id, "**Welcome to Tribal Council, #{tribes.map(&:mention).join(' ')}**")
                if sets.game_stage == 1
                    jury = Player.where(status: "Jury", season: sets.season)
                    if jury.size > 0
                        BOT.send_message(channel.id, "And welcome to the members of our" + event.server.role(965717073454043268).mention + ":")
                        BOT.send_message(channel.id, jury.map(&:name).join("\n"))
                    end
                end
                channel.start_typing
                sleep(2)
                BOT.send_message(channel.id, "Tonight, one of you seedlings will stop receiving resources. And when that happens, you will disappear..." )
                channel.start_typing
                sleep(2)
                BOT.send_message(channel.id, "But you can decide, as a group, which seedling should disappear. For that, you can use the `!vote` command in your submissions channel.")
                channel.send_embed do |embed|
                    embed.title = "Seedlings attending Tribal Council:"
                    embed.description = players.map(&:name).join("\n")
                    embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "You have more or less 24 hours to decide on who to vote!")
                    embed.color = tribes.map(&:color).sample
                end
                players.each do |player|
                    Vote.create(council: council.id, player: player.id)
                end
                channel.start_typing
                sleep(1)
                BOT.send_message(channel.id, "Good luck!")
            end
        else
        end
    end

end