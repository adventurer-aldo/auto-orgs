class Sunny

  BOT.command :prepare_elimination do |event|
    channel = BOT.channel(1393731026882269398)

    channel.send_embed do |embed|
      embed.title = "Alvivor S3: Spirits & Souls — Elimination Game"
      embed.description = "Before each challenge's results are posted, choose a castaway you think will **not** be eliminated during the episode's Tribal Council.\nIf your pick remains in the game... you're safe!\nIf your castaway leaves by means unrelated to the Tribal Council, you will be considered safe.\n\n**The spectator(s) that remain at the end, having good picks each episode... win the Elimination Game.**"
      embed.color = '#CB00FF'
    end

    players = Player.where(season_id: Setting.last.season, status: ALIVE)

    view = Discordrb::Webhooks::View.new
    view.row { |row| row.string_select(custom_id: "EliminationPick", options: players.map { |player| {label: player.name, value: player.id} }) }
    channel.send_message("**Who do you think will not be eliminated this episode?**", false, nil, nil, nil, nil, view)
  end

  BOT.string_select(custom_id: "EliminationPick") do |event|
    event.defer_update

    break if Council.where(season_id: Setting.last.season, stage: 0..4).exists?
    channel = BOT.channel(1393731026882269398)

    size = SpectatorGame::Elimination.all.size

    eliminator = SpectatorGame::Elimination.find_or_create_by(user_id: event.user.id, season_id: Setting.last.season)

    player = Player.find_by(id: event.values.first.to_i)

    eliminator.update(player_id: player.id)
    event.send_message(content: "You have decided to bet on **#{player.name}** not being eliminated this round.", ephemeral: true)

    if SpectatorGame::Elimination.all.reload.size == size
      channel.send_file(get_eliminator_image, filename: "Eliminator.png")
    end
  end
end