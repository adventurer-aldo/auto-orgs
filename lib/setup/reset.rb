class Sunny
    
    BOT.command :clean do |event|
        if HOSTS.include? event.user.id
            Challenge.destroy_all
            Clue.destroy_all
            Council.destroy_all
            Item.destroy_all
            Player.destroy_all
            Score.destroy_all
            Tribe.destroy_all
            Vote.destroy_all
            return "All Data has been destroyed successfuly!"
        else
            return "You don't have the permissions to do this command!"
        end
    end


end