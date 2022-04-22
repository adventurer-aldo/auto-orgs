class Sunny
    # > Item
    # > Council

    BOT.command :item, description: "Creates a new item to be claimed." do |event, *args|
        break unless HOSTS.include? event.user.id
        return "Not implemented yet."
    end

    BOT.command :council, description: "Creates a new Tribal Council channel and sets up everything related to." do |event|
        break unless HOSTS.include? event.user.id
        event.message.delete
        tribes = event.message.role_mentions
        event.respond("Input at least one tribe!") if tribes.size < 1
        break if tribes.size < 1


        @tribe = []
        @confirm = []
        @perms = [TRUE_SPECTATE, DENY_EVERY]
        @cast_left = Player.where(status: ALIVE+['Exiled'], season: Setting.last.season).size
        tribes.each do |tribe|
            unless Tribe.where(role_id: tribe.id).exists?
                @confirm << false
            else
                if Setting.last.tribes.include? Tribe.find_by(role_id: tribe.id).id
                    @tribe += [Tribe.find_by(role_id: tribe.id).id]
                    @perms += [Discordrb::Overwrite.new(tribe.id, allow: 3072)]
                else
                    @confirm << false
                end
            end
        end

        if Setting.last.game_stage == 1
            @perms += [JURY_SPECTATE]
        end

        if @confirm.include? false
            event.respond "One or more of those tribes do not exist in the database."
            return
        else
            sets = Setting.last
            players = Player.where(tribe: @tribe, status: ALIVE, season: sets.season)
            channel = event.server.create_channel("f#{@cast_left}-#{tribes.map(&:name).join('-')}",
            parent: COUNCILS,
            topic: "F#{@cast_left} Tribal Council. Tribes attending: #{tribes.map(&:name).join(', ')}",
            permission_overwrites: @perms)

            council = Council.create(tribe: @tribe, channel_id: channel.id)
            channel.start_typing
            sleep(6)
            BOT.send_message(channel.id, "**Welcome to Tribal Council, #{tribes.map(&:mention).join(' ')}**")
            if sets.game_stage == 1
                jury = Player.where(status: "Jury", season: sets.season)
                if jury.size > 0
                    channel.start_typing
                    sleep(4)
                    BOT.send_message(channel.id, "**And welcome to the members of our" + event.server.role(965717073454043268).mention + ":**")
                    channel.start_typing
                    sleep(2)
                    BOT.send_message(channel.id, "**" + jury.map(&:name).join("\n") + "**")
                    channel.start_typing
                    sleep(2)
                    BOT.send_message(channel.id, "...")
                end
            end
            channel.start_typing
            sleep(6)
            if Setting.last.game_stage == 0
                BOT.send_message(channel.id, "Tonight, one of you seedlings will stop receiving resources. And when that happens, you will disappear..." )
                channel.start_typing
                sleep(7)
                BOT.send_message(channel.id, "But you can decide, as a group, which seedling should disappear. For that, you can use the `!vote` command in your submissions channel.")
            else
                BOT.send_message(channel.id, "Tonight, you'll decide who you'll want to stay in this tribe with you." )
                channel.start_typing
                sleep(7)
                BOT.send_message(channel.id, "It is ultimately every seedling for itself, but you can decide in unison who you want gone. For that, you can use the `!vote` command in your submissions channel.")

            end

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
    end

    BOT.command :ftc, description: "Begins the Final Tribal Council." do |event|
        break unless HOSTS.include? event.user.id

        finalists = Player.where(status: ALIVE, season: Setting.last.season)
        jury_all = Player.where(status: 'Jury', season: Setting.last.season)

        Setting.last.game_stage = 2
        council = Council.create(tribe: [finalists.first.tribe], channel_id: event.server.create_channel(
            "final-tribal-council",
            topic: "The last time we'll read the votes during this season of Maskvivor.",
            parent: FTC,
            permission_overwrites: [DENY_EVERY, TRUE_SPECTATE]
        ).id)

        finalists.each do |finalist|
            channel = event.server.create_channel(finalist.name + '-speech',
            topic: "This is where #{finalist.name} will present a case to win the game.",
            parent: FTC,
            permission_overwrites: [EVERY_SPECTATE, Discordrb::Overwrite.new(finalist.user_id, type: 'member', allow: 3072)])
            Vote.create(player: finalist.id, council: council.id, allowed: 0, votes: [])
            channel.send_message("#{BOT.user(finalist.user_id).mention}")
        end
        
        jury_all.each do |jury|
            perms = finalists.map { |finalist| Discordrb::Overwrite.new(finalist.user_id, type: 'member', allow: 3072) }
            perms += [EVERY_SPECTATE, Discordrb::Overwrite.new(jury.user_id, type: 'member', allow: 3072)]
            channel = event.server.create_channel(jury.name + '-questions',
            topic: "#{jury.name} will be asking questions here, where the finalists will be able to clarify them.",
            parent: FTC,
            permission_overwrites: perms)
            Vote.create(player: jury.id, council: council.id, allowed: 1, votes: [])
            channel.send_message("#{BOT.user(jury.user_id).mention}")
        end

    end

end