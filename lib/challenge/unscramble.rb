class Sunny

  names = %w[karma pepsi idan mew lynn emerald iromi isaiah hunjax redpanda stew tabi]

  BOT.command :prepare do |event|
    break unless event.user.id.host?

    Player.where(season_id: Setting.season).each do |player|
      Challenges::Individual.create(player_id: player.id, stage: 0)
    end
  end

  BOT.command :unscramble do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)
    individual = player.individuals.first

    case individual.stage
    when 0
      individual.update(start_time: Time.now.to_i, stage: 1)
      event.respond "The challenge's timer will now begin! You'll receive a scrambled version of a castaway's name, and your task will be to guess who it is in **the fastest time!**"
      event.respond "The #{COUNTING[individual.stage].downcase} to unscramble is...\n**#{names[individual.stage].chars.shuffle.join('')}**"
    end
    return
  end

  BOT.command :karma do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)
    individual = player.individuals.first

    if individual.stage == 1
      individual.update(stage: individual.stage + 1)
      event.respond "That's correct! Next up...\nThe #{COUNTING[individual.stage].downcase} to unscramble is...\n**#{names[individual.stage].chars.shuffle.join('')}**"
    end
    return
  end

  BOT.command :pepsi do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)
    individual = player.individuals.first

    if individual.stage == 2
      individual.update(stage: individual.stage + 1)
      event.respond "That's correct! Next up...\nThe #{COUNTING[individual.stage].downcase} to unscramble is...\n**#{names[individual.stage].chars.shuffle.join('')}**"
    end
    return
  end

  BOT.command :idan do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)
    individual = player.individuals.first

    if individual.stage == 3
      individual.update(stage: individual.stage + 1)
      event.respond "That's correct! Next up...\nThe #{COUNTING[individual.stage].downcase} to unscramble is...\n**#{names[individual.stage].chars.shuffle.join('')}**"
    end
    return
  end

  BOT.command :mew do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)
    individual = player.individuals.first

    if individual.stage == 4
      individual.update(stage: individual.stage + 1)
      event.respond "That's correct! Next up...\nThe #{COUNTING[individual.stage].downcase} to unscramble is...\n**#{names[individual.stage].chars.shuffle.join('')}**"
    end
    return
  end

  BOT.command :lynn do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)
    individual = player.individuals.first

    if individual.stage == 5
      individual.update(stage: individual.stage + 1)
      event.respond "That's correct! Next up...\nThe #{COUNTING[individual.stage].downcase} to unscramble is...\n**#{names[individual.stage].chars.shuffle.join('')}**"
    end
    return
  end

  BOT.command :emerald do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)
    individual = player.individuals.first

    if individual.stage == 6
      individual.update(stage: individual.stage + 1)
      event.respond "That's correct! Next up...\nThe #{COUNTING[individual.stage].downcase} to unscramble is...\n**#{names[individual.stage].chars.shuffle.join('')}**"
    end
    return
  end

  BOT.command :iromi do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)
    individual = player.individuals.first

    if individual.stage == 7
      individual.update(stage: individual.stage + 1)
      event.respond "That's correct! Next up...\nThe #{COUNTING[individual.stage].downcase} to unscramble is...\n**#{names[individual.stage].chars.shuffle.join('')}**"
    end
    return
  end

  BOT.command :isaiah do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)
    individual = player.individuals.first

    if individual.stage == 8
      individual.update(stage: individual.stage + 1)
      event.respond "That's correct! Next up...\nThe #{COUNTING[individual.stage].downcase} to unscramble is...\n**#{names[individual.stage].chars.shuffle.join('')}**"
    end
    return
  end

  BOT.command :hunjax do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)
    individual = player.individuals.first

    if individual.stage == 9
      individual.update(stage: individual.stage + 1)
      event.respond "That's correct! Next up...\nThe #{COUNTING[individual.stage].downcase} to unscramble is...\n**#{names[individual.stage].chars.shuffle.join('')}**"
    end
    return
  end

  BOT.command :redpanda do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)
    individual = player.individuals.first

    if individual.stage == 10
      individual.update(stage: individual.stage + 1)
      event.respond "That's correct! Next up...\nThe #{COUNTING[individual.stage].downcase} to unscramble is...\n**#{names[individual.stage].chars.shuffle.join('')}**"
    end
    return
  end

  BOT.command :stew do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)
    individual = player.individuals.first

    if individual.stage == 11
      individual.update(stage: individual.stage + 1)
      event.respond "That's correct! Next up...\nThe #{COUNTING[individual.stage].downcase} to unscramble is...\n**#{names[individual.stage].chars.shuffle.join('')}**"
    end
    return
  end

  BOT.command :tabi do |event|
    next unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.season)
    individual = player.individuals.first

    if individual.stage == 12
      end_time = Time.now.to_i
      individual.update(stage: individual.stage + 1, end_time:)
      event.respond "That's correct! You got all the names right! Your total time was... **#{end_time - individual.start_time} seconds!**"
    end
    return
  end

end