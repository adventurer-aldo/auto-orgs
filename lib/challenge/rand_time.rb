class Sunny
  BOT.command :rand_time do |event|
    event.respond('The timer has started!')
    sleep(rand(30..100))
    event.respond("Time's up!")
  end

  BOT.command :reward_result do |event|
    break unless HOSTS.include? event.user.id

    event.respond(Challenge.all.order(end_time: :desc).map { |result| "**#{result.player.name}** — #{result.end_time - result.start_time}"}.join("\n"))
  end

  BOT.command :reward_challenge do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless [player.confessional, player.submissions].include? event.channel.id

    if Challenge.where(player_id: player.id).exists?
      if Challenge.where(player_id: player.id, end_time: nil).exists?
        chall = Challenge.where(player_id: player.id, end_time: nil).first
        time_now = Time.now.to_i
        chall.update(end_time: time_now)
        event.respond("You have submitted your score for the challenge. Your total time is **#{time_now - chall.start_time} seconds**.")
      else
        event.respond('You have already attempted this challenge!')
      end
    end
    break if Challenge.where(player_id: player.id).exists?

    Challenge.create(player_id: player.id, start_time: Time.now.to_i)
    event.respond("https://www.jigsawplanet.com/?rc=play&pid=1b4574b94683\nYour time begins...**NOW!**")
  end
end
