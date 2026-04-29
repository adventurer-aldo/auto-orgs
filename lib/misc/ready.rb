class Sunny
  BOT.ready do
    BOT.send_message(Setting.host_chat_channel_id, '# <a:torch:1400359863393062952> Hello! Our fruity world! <a:torch:1400359863393062952>')
    BOT.game = 'Resting'
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
    test = BOT.channel(1498777093616566473)
    conn = BOT.voice_connect(test)
    puts("Yeah. We go.")
    file = Shrine.storages[:store].open("tally_test.dca")
    conn.play_dca(file)
    conn.play_dca(file)
    BOT.send_message(Setting.host_chat_channel_id, "Looks like it's time to boil up.")
    conn.destroy
  end
end
