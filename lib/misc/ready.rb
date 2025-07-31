class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, 'Hello, new world!')
    BOT.game = 'with preparations for a new season!'
    view = Discordrb::Webhooks::View.new
    view.row { |row| row.string_select(custom_id: "WinnerPick", options: Player.all.map { |player| { label: player.name, value: player.id }})}
    BOT.channel(HOST_CHAT).send_message("Choose your Winner Pick!", false, nil, nil, nil, nil, view)
  end

  BOT.string_select(custom_id: "WinnerPick") do |event|
    event.defer_update

    event.channel.send_message("You chose **#{Player.find_by(id: event.values.first.to_i).name}**")
    draft = SpectatorGame::Draft.find_or_create_by(user_id: event.user.id, season_id: 2)
    draft.update(winner_pick: event.values.first.to_i)
  end
end
