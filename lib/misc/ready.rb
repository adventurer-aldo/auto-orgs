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
    puts("Yeah. We go.")
    url = "https://cdn.discordapp.com/attachments/1378044547287879731/1436473483688284170/output.dca?ex=690fbbae&is=690e6a2e&hm=f8edaf462920a310054f059cd1760774844533ad0af78db27840932c33d444c6&"
    conn.play_dca(url)
  end
end
