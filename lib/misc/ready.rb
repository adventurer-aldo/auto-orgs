class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, new world! <a:torch:1400359863393062952>')
    BOT.game = 'Season 3: Spirits & Souls!'
    score_strings = Setting.last.tribes.map do |tribe_id|
      t = Tribe.find_by(id: tribe_id)
      "#{t.name} — #{t.challenges.first.end_time} Points"
    end
    BOT.channel(1411757145036161044).send_message("**Current Progress of the Challenge for both tribes:**\n#{score_strings.join("\n")}")
  end
end
