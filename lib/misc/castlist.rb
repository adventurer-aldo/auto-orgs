class Sunny
  BOT.command :cast do |event|
    event.respond("**Castaways currently in the game:\n" + Player.where(status: ALIVE).pluck(:name).join("\n"))
  end
end