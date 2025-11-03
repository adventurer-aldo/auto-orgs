class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, our world! <a:torch:1400359863393062952>')
    BOT.game = 'Alvivor Season 4: ???!'
    make_item_commands

    test = BOT.channel(1434870641156423832)
    conn = BOT.voice_connect(test)
    sleep(5)
    conn.play_io(URI.parse("https://cdn.discordapp.com/attachments/1378044547287879731/1434872609996275733/stag.ogg?ex=6909e8c0&is=69089740&hm=53ed0b1adb2234b62bfef3b9e39993e39c9c5a9e8f8f9d32163fa5e7a4491617&").open)
    # Add Ons
   # hayden = Player.find_by(user_id: 198321560153489408, season_id: 2)
   # Search.where(player_id: hayden.id).update(player_id: Player.find_by(user_id: 198321560153489408, season_id: 3).id)
  end
end
