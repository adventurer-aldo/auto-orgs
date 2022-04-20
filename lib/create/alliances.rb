class Sunny

    BOT.command :alliance do |event, *args|
        player = Player.find_by(user_id: event.user.id, season: Setting.last.season, status: ALIVE)
        tribe = Tribe.find_by(id: player.tribe)
        if event.user.id.player? && event.server.role(tribe.role_id).members > 2
            enemies = Player.find_by(tribe: tribe.id, season: Setting.last.season, status: ALIVE).excluding(id: player.id)
        end
    end

end