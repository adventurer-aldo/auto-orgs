class Sunny
  def self.available_elimination_players_for(user_id)
    picked_ids = SpectatorGame::Elimination.where(user_id: user_id, season_id: Setting.season_id).where.not(player_id: nil).pluck(:player_id)
    Player.where(season_id: Setting.season_id, status: ALIVE).where.not(id: picked_ids).order(:id)
  end

  def self.prepare_elimination_game(channel = BOT.channel(Setting.spectator_elimination_channel_id))
    Setting.spectator_elimination_is_ongoing = 1

    channel.send_embed do |embed|
      embed.title = "#{season_title} — Elimination Game"
      embed.description = "Before each challenge's results are posted, choose a castaway you think will **not** be eliminated during the episode's Tribal Council.\nIf your pick remains in the game... you're safe!\nIf your castaway leaves by means unrelated to the Tribal Council, you will be considered safe.\n\n**The spectator(s) that remain at the end, having good picks each episode... win the Elimination Game.**"
      embed.color = '#CB00FF'
    end

    players = Player.where(season_id: Setting.season_id, status: ALIVE).order(:id)

    view = Discordrb::Webhooks::View.new
    view.row { |row| row.string_select(custom_id: "EliminationPick", options: players.first(25).map { |player| {label: player.name, value: player.id.to_s} }) }
    channel.send_message("**Who do you think will not be eliminated this episode?**", false, nil, nil, nil, nil, view)
  end

  BOT.command :prepare_elimination do |event|
    break unless event.user.id.host?

    prepare_elimination_game
  end

  BOT.string_select(custom_id: "EliminationPick") do |event|
    event.defer_update

    unless Setting.spectator_elimination_is_ongoing == 1 && spectator_games_open?
      event.send_message(content: 'Elimination Game picks are closed while Tribal Council is ongoing.', ephemeral: true)
      break
    end
    channel = BOT.channel(Setting.spectator_elimination_channel_id)

    size = SpectatorGame::Elimination.where(season_id: Setting.season_id).size

    episode = current_episode
    eliminator = SpectatorGame::Elimination.find_or_create_by(user_id: event.user.id, season_id: Setting.season_id, episode_id: episode.id)

    available_players = available_elimination_players_for(event.user.id)
    if available_players.empty?
      mark_spectator_game_lost(eliminator)
      event.send_message(content: 'No eligible alive castaways remain for you to pick. You have lost the Elimination Game.', ephemeral: true)
      break
    end

    player = available_players.find_by(id: event.values.first.to_i)
    unless player
      event.send_message(content: 'That castaway is unavailable. You can only pick alive players you have not picked before.', ephemeral: true)
      break
    end

    if ALIVE.include? player.status
      eliminator.update(player_id: player.id)
      event.send_message(content: "You have decided to bet on **#{player.name}** not being eliminated this round.", ephemeral: true)
    else
      event.send_message(content: "**#{player.name}** is long gone...", ephemeral: true)
    end


    if SpectatorGame::Elimination.where(season_id: Setting.season_id).reload.size != size
      channel.send_file(get_eliminator_image, filename: "Eliminator.png")
    end
  end
end
