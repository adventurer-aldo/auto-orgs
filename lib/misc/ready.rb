class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, new world! <a:torch:1400359863393062952>')
    BOT.game = 'Season 3: Spirits & Souls!'
    view = Discordrb::Webhooks::View.new
    view.row { |row| row.button(custom_id: "application_start_button", label: "Start Application", style: 3) }
    embed = Discordrb::Webhooks::Embed.new
    embed.title = "Applications for Alvivor Season 3: Spirits & Souls"
    embed.description = "Alumni (for a maximum of 6) and newbies are allowed to apply. \nClick the button below to begin your application!"
    embed.color = "1cc79c4"
    BOT.channel(1128055783519686756).send_message("", false, embed, nil, nil, nil, view)
  end

  BOT.string_select(custom_id: "WinnerPick") do |event|
    event.defer_update

    event.channel.send_message("You chose **#{Player.find_by(id: event.values.first.to_i).name}**")
    draft = SpectatorGame::Draft.find_or_create_by(user_id: event.user.id, season_id: 2)
    draft.update(winner_pick: event.values.first.to_i)
  end
end
