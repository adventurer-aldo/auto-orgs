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

  BOT.command(:cast, aliases: [:castlist]) do |event, *args|
    season_id = args.first&.to_i&.positive? ? args.first.to_i : Setting.season_id
    season = Season.find_by(id: season_id)
    unless season
      event.respond("Season #{season_id} doesn't exist.")
      break
    end

    players = Player.where(season_id: season.id).order(:rank, :name)
    lines = players.map do |player|
      rank = player.rank ? "#{ordinal(player.rank)} - " : ''
      "#{rank}#{player.name}#{ALIVE.include?(player.status) ? '' : " (#{player.status})"}"
    end
    event.respond("**Season #{season.id} Castaways:**\n#{lines.join("\n")}")
  end

  BOT.command :vote_count do |event|
    new_council_votes = Council.last.votes.map(&:votes).flatten
    event.respond("#{new_council_votes.size - new_council_votes.count(0)}/#{new_council_votes.size}")
  end
end
