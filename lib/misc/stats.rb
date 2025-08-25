class Sunny

  BOT.command :season_timer do |event|
    break unless event.user.id.host?
    InServerStats.enqueue(job_options: {run_at: Time.now.to_i})
  end

  BOT.command :stats do |event|
    return "You haven't played in Alvivor yet..." unless Player.where(user_id: event.user.id).exists?

    players = Player.where(user_id: event.user.id)
    event.respond("**Seasons Played:** #{players.size}\n**Tribal Councils attended:** #{players.map(&:votes).flatten.count}")
  end

end