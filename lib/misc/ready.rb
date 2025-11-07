class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello! ....Our musical world? <a:torch:1400359863393062952>')
    # BOT.game = 'Alvivor Season 4:'
    #make_item_commands
    # Add Ons
   # hayden = Player.find_by(user_id: 198321560153489408, season_id: 2)
   # Search.where(player_id: hayden.id).update(player_id: Player.find_by(user_id: 198321560153489408, season_id: 3).id)
  end

  BOT.command :aaa do |event|
    test = BOT.channel(1434870641156423832)
    conn = BOT.voice_connect(test)
    puts("Yeah.")
    a = Tempfile.new(["output", ".raw"])
    b = URI.parse("https://cdn.discordapp.com/attachments/1378044547287879731/1436347056762650838/output.raw?ex=690f45f0&is=690df470&hm=a6d02e56f4e0f885397971377d4df27a807fc9215507a4846b8bf86a627c70d8&").read
    a.write(b)
    conn.play(a.path)
  end
end
