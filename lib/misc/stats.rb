class Sunny

  BOT.command :stats do |event|
    return "You haven't played in Alvivor yet..." unless Player.where(user_id: event.user.id).exists?

    players = Player.where(user_id: event.user.id)
    event.respond("**Seasons Played:** #{players.size}\n**Tribal Councils attended:** #{players.map(&:votes).flatten.count}")
  end

end