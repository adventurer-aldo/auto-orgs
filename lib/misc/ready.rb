class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, our world! <a:torch:1400359863393062952>')
    BOT.game = 'Alvivor Season 4: ???!'
    make_item_commands

    # Add Ons
   # hayden = Player.find_by(user_id: 198321560153489408, season_id: 2)
   # Search.where(player_id: hayden.id).update(player_id: Player.find_by(user_id: 198321560153489408, season_id: 3).id)
  end
end
