class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, new world! <a:torch:1400359863393062952>')
    BOT.game = 'Season 3: Spirits & Souls!'
    council = Council.last
    council_tribes = council.tribes.map { |r| Tribe.find_by(id: r) }
    council_tribes.each do |tribed|
      BOT.channel(tribed.channel_id).define_overwrite(BOT.server(ALVIVOR_ID).role(tribed.role_id), 3072, 0)
      BOT.channel(tribed.channel_id).send_message("**Open!**")
      BOT.channel(tribed.cchannel_id).define_overwrite(BOT.server(ALVIVOR_ID).role(tribed.role_id), 3072, 0)
      BOT.channel(tribed.cchannel_id).send_message("**Open!**")
    end
  end
end
