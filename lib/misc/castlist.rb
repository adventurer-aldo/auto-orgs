class Sunny
  BOT.command :cast do |event|
    event.respond("**Castaways currently in the game:**\n" + Player.where(status: ALIVE, season_id: Setting.last.season).pluck(:name).join("\n"))
  end

  BOT.command :vote_count do |event|
    new_council_votes = Council.last.votes.map(&:votes).flatten
    event.respond("#{new_council_votes.size - new_council_votes.count(0)}/#{new_council_votes.size}")
  end
end