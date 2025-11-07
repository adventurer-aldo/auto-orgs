class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello! Our musical world! <a:torch:1400359863393062952>')
    # BOT.game = 'Alvivor Season 4:'
    #make_item_commands
    # Add Ons
    # hayden = Player.find_by(user_id: 198321560153489408, season_id: 2)
    # Search.where(player_id: hayden.id).update(player_id: Player.find_by(user_id: 198321560153489408, season_id: 3).id)
    test = BOT.channel(1434870641156423832)
    conn = BOT.voice_connect(test)
    puts("Yeah.")
    conn.play_file("https://cdn.discordapp.com/attachments/1378044547287879731/1436314774622310441/tally.ogg?ex=690f27df&is=690dd65f&hm=b209d8878d0377d0f72839398787c0191e375fb666e48265451e40151bf82f7b&")
  end
end
