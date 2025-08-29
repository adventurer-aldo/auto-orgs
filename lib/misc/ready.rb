class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, new world! <a:torch:1400359863393062952>')
    BOT.game = 'Season 3: Spirits & Souls!'
    urls = ['https://cdn.discordapp.com/attachments/1409633533101736047/1410439407676162108/parchment-35.png?ex=68b2570f&is=68b1058f&hm=ced9370e45d120678526b1bf37f4c8d7ba2abc607aa2e39ba0f6191fed9817a4',
  'https://cdn.discordapp.com/attachments/1409633565913649292/1410440574141726831/1410440486845681705remix-1756345634843.png?ex=68b25825&is=68b106a5&hm=35df174849e1c8d86cac4b406f629b43baeeba490029c584cc912bb48ea2a3fd',
'https://cdn.discordapp.com/attachments/1409633751612522526/1410439575587000360/1410438196290129931remix-1756345352261.png?ex=68b25737&is=68b105b7&hm=303d729360a59085fde6bc0a881a9f5e9ac38d32231bdb476207c712f021273a',
'https://cdn.discordapp.com/attachments/1409633656623988756/1410442197861400689/1410441995058679974remix-1756346014890.png?ex=68b259a8&is=68b10828&hm=c3d3ce7087128d4930d514f4d9bfdc27363a2c26ad91dc6c5e6fb5200514623d']
    urls.each do |url|
      BOT.channel(HOST_CHAT).send_file(URI.parse(url).open, filename: 'Hey.png')
    end
    txt = BOT.channel(HOST_CHAT)
    txt.send_message(".")
    txt.send_message(".")
    txt.send_message("**Isaiah...**")
    txt.send_message("**The tribe has spoken.**")
    file = URI.parse('https://i.ibb.co/zm9tYcb/spoken.gif').open
    BOT.send_file(channel, file, filename: 'spoken.gif')
  end

  BOT.message(in: HOST_CHAT, from: 460766095188688903) do |event|
    event.channel.send_file(URI.parse('https://cdn.discordapp.com/attachments/1409633533101736047/1410439407676162108/parchment-35.png?ex=68b2570f&is=68b1058f&hm=ced9370e45d120678526b1bf37f4c8d7ba2abc607aa2e39ba0f6191fed9817a4').open, filename: 'Hey.png')
  end
end
