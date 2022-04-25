class Sunny

    BOT.command :play, description: "Plays an item." do |event, *args|
        break unless event.user.id.player?

        event.respond("You didn't write a code!") if args[0].nil?
        break if args[0].nil?

        player = Player.find_by(user_id: event.user.id, season: Setting.last.season)
        item = Item.where(code: args[0], owner: player.id, season: Setting.last.season)

        event.respond("You don't have any item with that code.") unless item.exists?
        break unless item.exists?

        item = item.first
        
        targets = item.targets
        unless targets == []
            event.respond("You've cancelled playing **#{item.name}**.")
            item.update(targets: []) 
        end
        break unless targets == []
            
        playItem(event,(args - [args[0]]), item)

    end

end