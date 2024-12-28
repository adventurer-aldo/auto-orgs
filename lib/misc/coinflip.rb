class Sunny
  BOT.command(:coinflip, description: 'Randomly get Heads or Tails.') do |event|
    event.respond("**#{['Heads!', 'Tails!'].sample}**")
  end

  BOT.command(:random, description: "Picks an item within a list separated by spaces.") do |event, *args|
    pool = args.join(' ').split('|')
    if pool.size.positive?
      event.respond("I choose #{pool.sample}")
    else
      event.respond('Not enough choices...')
    end
  end

  BOT.command(:confess, description: "Sends a message to all the confessionals.") do |event, *args|
    players = Player.where(status: ALIVE, season_id: Setting.last.season)
    players.each do |player|
      BOT.channel(player.confessional).send_message(args.join(' '))
    end
  end
end
