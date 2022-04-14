class Sunny

    BOT.command :season do |event, *args|
        if HOSTS.include? event.user.id
            newseason = Season.create(name: args.join(' '))
            Setting.update(season: newseason.id)
        end
    end

end