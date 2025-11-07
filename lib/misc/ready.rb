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
    url = "https://cdn.discordapp.com/attachments/1378044547287879731/1436350018448658634/output.wav?ex=690f48b2&is=690df732&hm=257c2b54d5c06b7835167469dbf0dc9f82fe4d3585c382e9949a629ba4498bcc&"
    conn.play_file(url)
  end
end
