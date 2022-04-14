class Sunny
    BOT.command :player do |event|
        Player.create(userid: event.user.id, name: event.user.name, season: Setting.last.season)
    end

    BOT.command :clean do |event|
        if HOSTS.include? event.user.id
            Challenge.destroy_all
            Clue.destroy_all
            Council.destroy_all
            Item.destroy_all
            Player.destroy_all
            Score.destroy_all
            Setting.destroy_all
            Tribe.destroy_all
            Vote.destroy_all
            "All Data has been destroying successfuly!"
        else
            "You don't have the permissions to do this command!"
        end
    end
end