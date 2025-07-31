class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, new world! <a:torch:1400359863393062952>')
    BOT.game = 'Season 3: Spirits & Souls!'
  end

  BOT.string_select(custom_id: "WinnerPick") do |event|
    event.defer_update

    event.channel.send_message("You chose **#{Player.find_by(id: event.values.first.to_i).name}**")
    draft = SpectatorGame::Draft.find_or_create_by(user_id: event.user.id, season_id: 2)
    draft.update(winner_pick: event.values.first.to_i)
  end
end
