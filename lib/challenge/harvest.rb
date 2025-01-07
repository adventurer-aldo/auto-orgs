class Sunny
  BOT.command :harvest do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless [player.confessional, player.submissions].include? event.channel.id

    event.respond('You have already started this challenge!') if Challenge.where(player_id: player.id).exists?
    break if Challenge.where(player_id: player.id).exists?

    Challenge.create(player_id: player.id, start_time: Time.now.to_i)
    event.respond("Which ''vegetable'' is said to actually be a fruit?")
  end

  BOT.command :tomato do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 0
    challenge.update(stage: 1)

    event.respond("Which vegetable is said to be related to enhancing sight/vision?")
  end

  BOT.command :carrot do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 1
    challenge.update(stage: 2)
    
    event.respond("Which vegetable is said to make you cry?")
  end

  BOT.command :onion do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 2
    challenge.update(stage: 3)
    
    event.respond("Lactuca sativa is the species name for...")
  end

  BOT.command :lettuce do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 3
    challenge.update(stage: 4)
    
    event.respond("Also called sunroots, wild sunflowers, topinambur or earth apples...what are those?")
  end

  BOT.command :sunchokes do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 4
    challenge.update(stage: 5)
    
    event.respond("Cosmopolitan group of more than 50 species which make up the genus of annual or short-lived perennial plants collectively known as?")
  end
  
  BOT.command :amaranths do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 5
    challenge.update(stage: 6)
    
    event.respond("Said to be significantly superior in Vitamin A than their counterpart. Those are the ...!")
  end
  
  BOT.command :sweet_potatoes do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 6
    challenge.update(stage: 7)
    
    event.respond("They have some sisters that are said to be spicy. The chilli... In this game, those are the:")
  end
  
  BOT.command :bell_peppers do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 7
    challenge.update(stage: 8)
    
    event.respond("Seeds that can be eaten, and are contained within a pod. The pod + the seeds are...")
  end
  
  BOT.command :pea_pods do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 8
    challenge.update(stage: 9)
    
    event.respond("Cylindrical to spherical, green vegetables, which are used as culinary vegetables, and the ones to attend the last Tribal Council.")
  end
  
  BOT.command :cucumbers do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 9
    challenge.update(stage: 10)
    
    event.respond("A dish typically made of mixed vegetables, fruits, or grains, often served cold, and dressed with oil, vinegar, or sauces. It can include proteins like chicken, fish, or beans. Its main components can be Lettuces, Tomatoes, Carrots or Onions...!")
  end
  
  BOT.command :salad do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
    break unless Challenge.where(player_id: player.id).exists?
    break unless [player.confessional, player.submissions].include? event.channel.id
    challenge = player.challenges.first

    break unless challenge.stage == 10
    current_time = Time.now.to_i
    challenge.update(end_time: current_time, stage: 11)
    
    event.respond("You have finished the challenge!\nYour total time was **#{current_time - challenge.start_time} seconds**!")
  end

end
