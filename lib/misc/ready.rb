class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, our world! <a:torch:1400359863393062952>')
    BOT.game = 'Season 4!'
    council_and_votes = Setting.season.councils.map { |council| council.votes.map { |vote| "**#{vote.player.name}** voted #{vote.votes.map { |vote_id| Player.find_by(id: vote_id).name}.join(', ')}"}.join("\n")}
    council_and_votes.each do |council_votes|
      BOT.send_message(HOST_CHAT, council_votes)
    end
    make_item_commands

    # Add Ons
   # hayden = Player.find_by(user_id: 198321560153489408, season_id: 2)
   # Search.where(player_id: hayden.id).update(player_id: Player.find_by(user_id: 198321560153489408, season_id: 3).id)
  end
end
