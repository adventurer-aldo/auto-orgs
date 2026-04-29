class Sunny
  def self.ordinal(number)
    return "#{number}th" if (11..13).include?(number % 100)

    suffix = case number % 10
             when 1 then 'st'
             when 2 then 'nd'
             when 3 then 'rd'
             else 'th'
             end
    "#{number}#{suffix}"
  end

  BOT.command :cast do |event|
    players = Player.where(season_id: Setting.season_id).order(:rank, :name)
    lines = players.map do |player|
      rank = player.rank ? "#{ordinal(player.rank)} - " : ''
      "#{rank}#{player.name}#{ALIVE.include?(player.status) ? '' : " (#{player.status})"}"
    end
    event.respond("**Season #{Setting.season_id} Castaways:**\n#{lines.join("\n")}")
  end

  BOT.command :vote_count do |event|
    new_council_votes = Council.last.votes.map(&:votes).flatten
    event.respond("#{new_council_votes.size - new_council_votes.count(0)}/#{new_council_votes.size}")
  end
end
