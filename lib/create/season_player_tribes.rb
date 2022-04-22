class Sunny
    # ========================================================
    # > Season
    # > Player
    # > Tribes
    # ========================================================
    
    BOT.command :season, description: "Creates a new season." do |event, *args|
        break unless HOSTS.include? event.user.id
        newseason = Season.create(name: args.join(' '))
        Setting.update(season: newseason.id, game_stage: 0)
        return "New season created!"
    end
    
    BOT.command :player, description: "Registers the user as a new player in the current season." do |event, *args|
        break unless HOSTS.include? event.user.id
        break unless event.message.mentions.size > 0
        event.message.mentions.each do |person|
            player =  Player.create(user_id: person.id, name: person.name, season: Setting.last.season,
            confessional: event.server.create_channel(
                person.name + '-confessional',
                parent: CONFESSIONALS,
                topic: person.name + "'s Confessional. Talk to the spectators about your game here!",
                permission_overwrites: [Discordrb::Overwrite.new(person.id, type: 'member', allow: 3072),
                TRUE_SPECTATE, DENY_EVERY]).id,
            submissions: event.server.create_channel(person.name + '-submissions',
                parent: CONFESSIONALS,
                topic: "Your Submissions channel. Submit challenge scores, check your inventory and play your items!",
                permission_overwrites: [Discordrb::Overwrite.new(person.id, type: 'member', allow: 3072),
                DENY_EVERY]).id)

                person.on(event.server).add_role(964564440685101076)
            BOT.send_message(player.confessional, "**Welcome to your confessional, <@#{person.id}>**\nThis is where you'll be talking about your game and the spectators will get a peek at your current mindset!")
            BOT.send_message(player.submissions, "**Welcome to your submissions channel!**\nHere you'll be putting your challenge scores, play, trade, receive items and submit your votes.\n\nTo start things off, check your inventory with `!inventory`!")
        end
    end

    BOT.command :tribes, description: "Creates new tribes and automatically puts alive seedlings in them." do |event, *args|
        break unless HOSTS.include? event.user.id
        event.message.delete
        tribes = event.message.role_mentions
        players = Player.where(season: Setting.last.season, status: ALIVE+['Exiled'])
        if tribes.size > 1
            if players.size % tribes.size == 0

                @set_tribes = []
                tribes.each do |tribe|
                    # > Voice Channel for the Tribe
                    #event.server.create_channel(tribe.name + ' Voice',2, parent: TRIBES,
                    #permission_overwrites: [Discordrb::Overwrite.new(tribe.id, allow: 3146752),
                    #Discordrb::Overwrite.new(EVERYONE, deny: 3146752)])
                    chan = event.server.create_channel(tribe.name + '-camp',
                    parent: TRIBES,
                    topic: tribe.name + "'s Camp. Hang around and plan with all your tribemates here. You'll be together for a while, so best make use of it!",
                    permission_overwrites: [TRUE_SPECTATE, DENY_EVERY,
                    Discordrb::Overwrite.new(tribe.id, allow: 3072)])
                    chan.send_message("Welcome to your new camp, #{tribe.mention}!\nHope you have fun!")

                    @set_tribes << Tribe.create(name: tribe.name,
                    role_id: tribe.id,
                    channel_id: chan.id,
                    season: Setting.last.season).id
                end
                Setting.last.update(tribes: @set_tribes)

                @buffs = []
                (players.size/tribes.size).times do 
                    @buffs += Array(0..(tribes.size - 1))
                end
                @buffs.shuffle!
                event.respond "It's time to swap between " + tribes.map(&:mention).join(" ") + "!"
                event.channel.start_typing
                sleep(2)
                event.respond "Come and take your buffs, veggies!"
                event.channel.start_typing
                sleep(2)
                event.respond "First up, #{players[0].name}. Come here!"
                puts @buffs.to_s
                players.shuffle.each do |player|
                    event.channel.start_typing
                    sleep(2)
                    event.respond "**#{player.name} takes a buff...**"
                    rand = @buffs.sample
                    puts rand.to_s
                    event.channel.start_typing
                    sleep(3)
                    event.respond "...the buff taken out was from..."
                    event.channel.start_typing
                    sleep(3)
                    event.respond "**Tribe #{tribes[rand].mention}!**"
                    player.update(tribe: Tribe.find_by(role_id: tribes[rand].id).id)
                    @buffs.delete_at(@buffs.index(rand))
                    sleep(2)
                end

                players.each do |player|
                    BOT.user(player.user_id).on(event.server).add_role(Tribe.find_by(id: player.tribe).role_id)
                end

                return "And that's about it. Go meet your new tribemates!"
            else
                return "There's not enough seeds to split equally amongst those roles."
            end
        elsif tribes.size == 1
            event.respond "You've only selected one tribe. **This will start Merge.**\nAre you sure about it?"
            @confirm = false
            loop do 
                event.message.await!(timeout: 30) do |confirm_event|
                    if confirm_event.message.content.downcase == "yes"
                        @confirm = true
                        @merge = true
                    elsif confirm_event.message.content.downcase == "no"
                        event.respond "Got it"
                        @confirm = true
                        @merge = false
                    end
                end
                break if @confirm == true
            end
                
            if @confirm == true && @merge == true
                begin
                    File.open('./lib/setup/merge_cheers.txt', 'r') do |file|
                        @cheers = file.readlines
                        file.close
                    end
                rescue Errno::ENOENT
                    @cheers = ["%s takes a buff..."]
                end
                event.respond "**Merge has begun!**"
                event.respond "Seeds that are voted off from now on will make part of the #{tribes[0].mention}"
                sleep(5)
                event.respond "Welcome your last partners and/or foes in the last stage of the game!"

                
                @set_tribes = []
                tribes.each do |tribe|
                    # Voice
                    #event.server.create_channel(tribe.name,2,
                    #permission_overwrites: [Discordrb::Overwrite.new(tribe.id, allow: 3146752),
                    #Discordrb::Overwrite.new(EVERYONE, deny: 3146752)])
                    chan = event.server.create_channel(tribe.name + '-camp',
                    parent: TRIBES,
                    topic: tribe.name + "'s Camp. Hang around, discuss and/or play around with your friends and enemies. You'll be together for the rest of your journey...",
                    permission_overwrites: [TRUE_SPECTATE, DENY_EVERY,
                    Discordrb::Overwrite.new(tribe.id, allow: 3072)])

                    chan.send_message("Welcome to your new camp, #{tribe.mention}!\nHope you have fun!")

                    @set_tribes << Tribe.create(name: tribe.name,
                    role_id: tribe.id,
                    channel_id: chan.id,
                    season: Setting.last.season).id
                end
                Setting.last.update(tribes: @set_tribes, game_stage: 1)

                players.each do |player|
                    player.update(tribe: Tribe.find_by(role_id: tribes[0].id).id)
                    BOT.user(player.user_id).on(event.server).add_role(Tribe.find_by(id: player.tribe).role_id)
                    event.respond sprintf(@cheers.sample, BOT.user(player.user_id).mention)
                    sleep(3)
                end

                event.respond "Congratulations, and welcome to the beginning of the **Endgame**."
            end

            return
        else
            return "You need to select at least one **tribe**!"
        end
    end

end