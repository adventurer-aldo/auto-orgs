class Sunny
  BOT.command :trust_ranking do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless [player.confessional, player.submissions].include? event.channel.id

    # event.respond("You're not eligible for this challenge!") unless [10, 17].include?(player.id)
    # break unless [10, 17].include?(player.id)

    event.respond('You have already started this challenge!') if Challenge.where(player_id: player.id).exists?
    break if Challenge.where(player_id: player.id).exists?

    Challenge.create(player_id: player.id, start_time: Time.now.to_i)
    event.respond("oneknr")
  end

  BOT.command :konner do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 0
    challenge.update(stage: 1)

    event.respond("nrorci")
  end

  BOT.command :corrin do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 1
    challenge.update(stage: 2)

    event.respond("rcma")
  end

  BOT.command :marc do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 2
    challenge.update(stage: 3)
    
    event.respond("alxe")
  end

  BOT.command :alex do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 3
    challenge.update(stage: 4)
    
    event.respond("yafe")
  end

  BOT.command :faye do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 4
    challenge.update(stage: 5)
    
    event.respond("eas")
  end

  BOT.command :esa do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 5
    challenge.update(stage: 6)
    
    event.respond("ytanotga")
  end

  BOT.command :tangytao do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 6
    challenge.update(stage: 7)
    
    event.respond("ofo")
  end

  BOT.command :foo do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 7
    challenge.update(stage: 8)
    
    event.respond("jd")
  end

  BOT.command :dj do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 8
    challenge.update(stage: 9)
    
    event.respond("ahsiai")
  end
  
  BOT.command :isaiah do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 9
    current_time = Time.now.to_i
    challenge.update(end_time: current_time, stage: 10)
    
    event.respond("You have finished the challenge!\nYour total time was **#{current_time - challenge.start_time} seconds**!")
  end

end
