class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello! Our musical world! <a:torch:1400359863393062952>')
    # BOT.game = 'Alvivor Season 4:'
    #make_item_commands
    # Add Ons
    # hayden = Player.find_by(user_id: 198321560153489408, season_id: 2)
    # Search.where(player_id: hayden.id).update(player_id: Player.find_by(user_id: 198321560153489408, season_id: 3).id)
  end

  BOT.command :store do |event, *args|
    return "You didn't upload anything in your message!" unless event.message.attachments.size.positive?
    return "You didn't write a filename!" unless args.size.positive?
    
    Shrine.storages[:store].upload(URI.parse(event.message.attachments[0].url), args.join(''))
  end
  
  BOT.command :retrieve do |event, *args|
    return "You didn't write a filename!" unless args.size.positive?

    event.channel.send_file(Shrine.storages[:store].open(args.join('')), filename: args.join(''))
  end

  BOT.command :aaa do |event|
    test = BOT.channel(1434870641156423832)
    conn = BOT.voice_connect(test)
    puts("Yeah. We go.")
    url = "https://cdn.discordapp.com/attachments/1378044547287879731/1436473483688284170/output.dca?ex=690fbbae&is=690e6a2e&hm=f8edaf462920a310054f059cd1760774844533ad0af78db27840932c33d444c6&"
    conn.play_dca(URI.parse(url).open)
    BOT.send_message(HOST_CHAT, "Looks like it's time to boil up.")
  end
end
