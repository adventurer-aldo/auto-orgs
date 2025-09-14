class Sunny
  BOT.command :tribes, description: 'Creates new tribes and automatically puts alive castaways in them.' do |event, *args|
    break unless HOSTS.include? event.user.id

    tribes = event.message.role_mentions
    players = Player.where(season_id: Setting.season, status: ALIVE + ['Exiled'])
    if tribes.size > 1
      if (players.size % tribes.size).zero?
        @set_tribes = []
        tribes.each do |tribe|
          # > Voice Channel for the Tribe
          vchan = event.server.create_channel(tribe.name + ' Voice',2, parent: TRIBES,
          permission_overwrites: [Discordrb::Overwrite.new(tribe.id, allow: 3146752),
          Discordrb::Overwrite.new(EVERYONE, deny: 3146752)])
          cchan = event.server.create_channel(tribe.name + '-challenges',
            parent: TRIBES,
            topic: tribe.name + "'s Challenges channel. This is where you'll submit challenges-related stuff or play in them if needed.",
            permission_overwrites: [TRUE_SPECTATE, DENY_EVERY_SPECTATE,
            Discordrb::Overwrite.new(tribe.id, allow: 3072)])
          chan = event.server.create_channel(tribe.name + '-camp',
          parent: TRIBES,
          topic: tribe.name + "'s Camp. Hang around and plan with all your tribemates here. You'll be together for a while, so best make use of it!",
          permission_overwrites: [TRUE_SPECTATE, DENY_EVERY_SPECTATE,
          Discordrb::Overwrite.new(tribe.id, allow: 3072)])
          chan.send_message("Welcome to your new camp, #{tribe.mention}!\nMeet your tribemates!")

          @set_tribes << Tribe.create(name: tribe.name,
          role_id: tribe.id,
          channel_id: chan.id,
          vchannel_id: vchan.id,
          cchannel_id: cchan.id,
          season_id: Setting.season).id
        end
        Setting.last.update(tribes: @set_tribes)

        @buffs = []
        (players.size/tribes.size).times do 
          @buffs += Array(0..(tribes.size - 1))
        end
        @buffs.shuffle!
        event.respond "It's time to swap between #{tribes.map(&:mention).join(' ')}!"
        event.channel.start_typing
        sleep(1)
        event.respond 'Come and take your buffs, survivors!'
        event.channel.start_typing
        sleep(1)
        players = players.shuffle
        event.respond "First up, #{players[0].name}. Come here!"
        players.each do |player|
          event.channel.start_typing
          sleep(1)
          event.respond "**#{BOT.user(player.user_id).mention} takes a buff...**"
          rand = @buffs.sample
          event.channel.start_typing
          sleep(1)
          event.respond '...the buff taken out was from...'
          event.channel.start_typing
          sleep(1)
          event.respond "**Tribe #{tribes[rand].mention}!**"
          player.update(tribe_id: Tribe.where(role_id: tribes[rand].id).last.id)
          @buffs.delete_at(@buffs.index(rand))
          event.channel.start_typing
          sleep(2)
          event.respond '.'
        end

        players.each do |player|
          BOT.user(player.user_id).on(event.server).add_role(player.tribe.role_id)
          BOT.channel(player.confessional).name = player.tribe.name.gsub(/[a-zA-Z0-9\s]+/, "") + player.name + '-confessional'
          BOT.channel(player.submissions).name = player.tribe.name.gsub(/[a-zA-Z0-9\s]+/, "") + player.name + '-submissions'
        end

        return "And that's about it. Go meet your new tribemates!"
      else
        return "There's not enough castaways to split equally amongst those roles."
      end
    elsif tribes.size == 1
      event.respond "You've only selected one tribe. **This will start Merge.**\nAre you sure about it?"
      @confirm = false
      loop do
        event.message.await!(timeout: 30) do |confirm_event|
          if confirm_event.message.content.downcase == 'yes'
            @confirm = true
            @merge = true
          elsif confirm_event.message.content.downcase == 'no'
            event.respond 'Got it'
            @confirm = true
            @merge = false
          end
        end
        break if @confirm == true
      end

      if @confirm == true && @merge == true
        begin
          File.open('./lib/create/merge_cheers.txt', 'r') do |file|
            @cheers = file.readlines
            file.close
          end
        rescue Errno::ENOENT
          @cheers = ['%s takes a buff...']
        end
        event.channel.start_typing
        sleep(3)
        event.respond '**Merge has begun!**'
        event.channel.start_typing
        sleep(6)
        event.respond "Castaways that are voted off from now on will make part of the #{event.server.role(JURY).mention}"
        event.channel.start_typing
        sleep(5)
        event.respond 'Welcome your last partners and/or foes in the last stage of the game!'
        event.channel.start_typing
        sleep(3)
        event.respond '.'

        @set_tribes = []
        tribes.each do |tribe|
          # Voice
          vchan = event.server.create_channel(tribe.name,2,
          parent: TRIBES,
          permission_overwrites: [Discordrb::Overwrite.new(tribe.id, allow: 3146752),
          Discordrb::Overwrite.new(EVERYONE, deny: 3146752)])
          chan = event.server.create_channel(tribe.name + '-camp',
          parent: TRIBES,
          topic: "#{tribe.name}'s Camp. Hang around, discuss and/or play around with your friends and enemies. You'll be together for the rest of your journey...",
          permission_overwrites: [TRUE_SPECTATE, DENY_EVERY_SPECTATE,
          Discordrb::Overwrite.new(tribe.id, allow: 3072)])
          cchan = event.server.create_channel(tribe.name + '-challenges',
            parent: TRIBES,
            topic: "#{tribe.name}'s Challenges channel. This is where you'll team up or pit against each other when needed...",
            permission_overwrites: [TRUE_SPECTATE, DENY_EVERY_SPECTATE,
            Discordrb::Overwrite.new(tribe.id, allow: 3072)])

          chan.send_message("Welcome to your new camp, #{tribe.mention}!\nMeet your tribemates!")

          @set_tribes << Tribe.create(
            name: tribe.name,
            role_id: tribe.id,
            channel_id: chan.id,
            vchannel_id: vchan.id,
            cchannel_id: cchan.id,
            season_id: Setting.season
          ).id
        end
        Setting.last.update(tribes: @set_tribes, game_stage: 1)

        players.each do |player|
          player.update(tribe_id: Tribe.where(season: Setting.season, role_id: tribes[0].id).last.id)
          BOT.user(player.user_id).on(event.server).add_role(player.tribe.role_id)
          BOT.channel(player.confessional).name = player.tribe.name.gsub(/[a-zA-Z0-9\s]+/, "") + player.name + '-confessional'
          BOT.channel(player.submissions).name = player.tribe.name.gsub(/[a-zA-Z0-9\s]+/, "") + player.name + '-submissions'
          event.channel.start_typing
          sleep(3)
          event.respond format(@cheers.sample, BOT.user(player.user_id).mention)
          sleep(2)
        end

        event.channel.start_typing
        sleep(3)
        event.respond '.'
        event.channel.start_typing
        sleep(5)
        event.respond 'Congratulations, and welcome to the beginning of the **Endgame**.'
      end

      return
    else
      return 'You need to select at least one **tribe**!'
    end
  end
end