class Sunny

  BOT.command :puzzle do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)

    challenge = player.challenges.last

    if challenge.start_time.nil?
      challenge.update(start_time: Time.now.to_i)
      event.respond("The timer has started! Submit a screenshot of the completed puzzle, and then use the command `!end_puzzle` to finish this challenge.\nNot submitting a screenshot will incur the penalty of **2 hours!**")
      event.respond("https://www.jigsawplanet.com/?rc=play&pid=1e4adfefc2a6")
    end
  end

  BOT.command :end_puzzle do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)

    challenge = player.challenges.last

    if !challenge.start_time.nil? && challenge.end_time.nil?
      end_time = Time.now.to_i

      challenge.update(end_time:)
      event.respond("You signaled that you have ended the challenge! Your supposed time is **#{end_time - challenge.start_time} seconds.**")
    end
  end

end