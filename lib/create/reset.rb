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

    BOT.command :remove, description: "Removes a role from all its members." do |event|
        break unless HOSTS.include? event.user.id
        event.respond("You have to mention at least one role!") if event.message.role_mentions.size < 1
        break if event.message.role_mentions.size < 1
    end


end