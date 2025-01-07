class Sunny
  BOT.command :harvest do |event|
    break # unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless [player.confessional, player.submissions].include? event.channel.id

    event.respond('You have already started this challenge!') if Challenge.where(player_id: player.id).exists?
    break if Challenge.where(player_id: player.id).exists?

    Challenge.create(player_id: player.id, start_time: Time.now.to_i)
    event.respond("Which ''vegetable'' is said to actually be a fruit?")
  end

  BOT.command :tomato do |event|
    break unless Challenge.where(player_id: player.id).exists?
    event.respond("Which vegetable is said to be related to enhancing sight/vision?")
  end
end
