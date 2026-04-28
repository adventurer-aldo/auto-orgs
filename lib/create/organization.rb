class Sunny
  BOT.command :info do |event|
    break unless event.user.id.host?

    Player.where(season_id: Setting.season).each do |player|
      event.channel.send_embed do |embed|
        embed.title = player.name
        embed.description = "**ID:** #{player.id}\n**Status:** #{player.status}\n**Confessional/Submissions:** #{player.confessional}/#{player.submissions}"
      end
    end
  end
end
