class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, new world! <a:torch:1400359863393062952>')
    BOT.game = 'Season 3: Spirits & Souls!'
    
  end

  BOT.message(in: HOST_CHAT, from: 460766095188688903) do |event|
    event.channel.send_file(URI.parse('https://cdn.discordapp.com/attachments/1409633533101736047/1410439407676162108/parchment-35.png?ex=68b2570f&is=68b1058f&hm=ced9370e45d120678526b1bf37f4c8d7ba2abc607aa2e39ba0f6191fed9817a4'), filename: 'Hey.png')
  end
end
