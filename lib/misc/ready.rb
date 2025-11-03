class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, our world! <a:torch:1400359863393062952>')
    BOT.game = 'Alvivor Season 4: ???!'
    make_item_commands

    test = BOT.channel(1434870641156423832)
    conn = BOT.voice_connect(test)
    sleep(5)
    conn.play_io(URI.parse("https://cdn.discordapp.com/attachments/1378044547287879731/1434872190402170960/Tally_the_Vote_-_Game_Changers_5DSrD4yt2Ec.opus?ex=6909e85c&is=690896dc&hm=6beb804b95cc7718fd273a1c064095249fed5d4551158bc4dd2a6bde6571719e&").open)
    # Add Ons
   # hayden = Player.find_by(user_id: 198321560153489408, season_id: 2)
   # Search.where(player_id: hayden.id).update(player_id: Player.find_by(user_id: 198321560153489408, season_id: 3).id)
  end
end
