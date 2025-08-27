class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, new world! <a:torch:1400359863393062952>')
    BOT.game = 'Season 3: Spirits & Souls!'
    BOT.channel(1409959696349139025).load_message(1410340219491713164).edit "Using 3 guesses, **Habiti🌕** guessed a word correctly! 1/6"
  end
end
