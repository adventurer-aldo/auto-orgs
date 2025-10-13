class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, our world! <a:torch:1400359863393062952>')
    BOT.game = 'Season 4!'
    council_and_votes = Setting.season.councils.map do |council| 
      council.votes.map do |vote| 
        names = vote.votes.map do |vote_id| 
          vote_id == 0 ? "nobody" : Player.find_by(id: vote_id).name
        end.join(', ')
        "**#{vote.player.name}** voted #{names}"
      end.join("\n")
    end
    council_and_votes.each_with_index do |council_votes, index|
      BOT.send_message(HOST_CHAT, "# Tribal Council No. #{index + 1}")
      
      BOT.send_message(HOST_CHAT, council_votes)
      sleep(30)
    end
    make_item_commands

    # Add Ons
   # hayden = Player.find_by(user_id: 198321560153489408, season_id: 2)
   # Search.where(player_id: hayden.id).update(player_id: Player.find_by(user_id: 198321560153489408, season_id: 3).id)
  end
end
