class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, new world! <a:torch:1400359863393062952>')
    BOT.game = 'Season 3: Spirits & Souls!'
    
  end

  BOT.message(in: HOST_CHAT, from: 460766095188688903) do |event|
    BOT.channel(HOST_CHAT).send_message(event.message.content)
  end
end
