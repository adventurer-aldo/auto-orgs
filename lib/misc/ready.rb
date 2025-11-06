class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, and our world! <a:torch:1400359863393062952>')
    BOT.game = 'Alvivor Season 4: ???!'
    make_item_commands

    test = BOT.channel(1434870641156423832)
    conn = BOT.voice_connect(test, false)
    sleep(5)
    puts("Yeah.")
    conn.play_dca("https://cdn.discordapp.com/attachments/1378044547287879731/1434886839155560541/testaudio.dca?ex=6909f601&is=6908a481&hm=e6a70cb16f88488b856d314cca7b8fb4c8674ac4941a04abf9758c9de81ef409&")
    # Add Ons
   # hayden = Player.find_by(user_id: 198321560153489408, season_id: 2)
   # Search.where(player_id: hayden.id).update(player_id: Player.find_by(user_id: 198321560153489408, season_id: 3).id)
  end
end
