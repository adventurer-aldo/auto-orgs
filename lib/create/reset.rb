class Sunny
    
    BOT.command :clean, description: "Delete all Data except Settings." do |event|
        break unless HOSTS.include? event.user.id
        Vote.destroy_all
        Council.destroy_all
        Clue.destroy_all
        Item.destroy_all
        Alliance.destroy_all
        Player.destroy_all
        Tribe.destroy_all
        Score.destroy_all
        Challenge.destroy_all
        return "All Data has been destroyed successfuly!"
    end

    BOT.command :prune, description: "Cleans up a channel." do |event|
        break unless HOSTS.include? event.user.id
        event.channel.prune(100)
        return
    end

    BOT.command :update, description: "Updates the item list so that new codes can be found." do |event|
        break unless HOSTS.include? event.user.id
        make_item_commands
        event.respond("The items list has been updated!")
    end

    make_item_commands
end