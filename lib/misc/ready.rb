class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello! ....Our musical world? <a:torch:1400359863393062952>')
    # BOT.game = 'Alvivor Season 4:'
    #make_item_commands
    # Add Ons
   # hayden = Player.find_by(user_id: 198321560153489408, season_id: 2)
   # Search.where(player_id: hayden.id).update(player_id: Player.find_by(user_id: 198321560153489408, season_id: 3).id)
   test = BOT.channel(1434870641156423832)
   conn = BOT.voice_connect(test)
   puts("Yeah.")
   conn.play_dca(URI.parse("https://cdn.discordapp.com/attachments/1378044547287879731/1434886839155560541/testaudio.dca?ex=690f3c01&is=690dea81&hm=ecbbcb1a765ff8409eadb628b3f8b6f5b97bd57bd1a1cbfec29fcda1289415db&").open)
  end
end
