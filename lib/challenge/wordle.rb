class Sunny
  @wordles = File.readlines('./texts/wordles.txt', chomp: true)
  @guessles = File.readlines('./texts/guessles.txt', chomp: true)

  def self.wordle_word_value(word)
    column = %w[word text value answer].find { |name| word.has_attribute?(name) }
    column ? word[column].to_s.downcase : ''
  end

  def self.wordle_targets_for(tribe)
    opposing_tribe_ids = Setting.tribes - [tribe.id]
    Challenges::Wordle::Word.where(tribe_id: opposing_tribe_ids).order(:id).map { |word| wordle_word_value(word) }.reject(&:empty?)
  end
  
  BOT.message(in: Setting.tribes.map { |tribe_id| Tribe.find_by(id: tribe_id).cchannel_id }) do |event|
    player = Player.find_by(user_id: event.user.id, season_id: Setting.season_id)

    return if player.nil?

    tribe = player.tribe

    challenge = Challenges::Tribal.find_by(tribe_id: tribe.id)

    return if challenge.nil?

    target_words = wordle_targets_for(tribe)
    return if target_words.empty?
    return if challenge.stage >= target_words.size

    target = target_words[challenge.stage]
    
    guess = event.message.content.downcase

    unless (@wordles + @guessles).include?(guess)
      puts "Someone guessed wordle incorrectly...."
      next
    end

    challenge.update(end_time: challenge.end_time + 1)

    result = Array.new(guess.length, ":white_large_square:")
    target_chars = target.chars
    guess_chars  = guess.chars

    # count available letters in target
    letter_count = Hash.new(0)
    target_chars.each { |c| letter_count[c] += 1 }

    # first pass: greens
    guess_chars.each_with_index do |char, i|
      if char == target_chars[i]
        result[i] = ":green_square:"
        letter_count[char] -= 1
      end
    end

    # second pass: yellows
    guess_chars.each_with_index do |char, i|
      next if result[i] == ":green_square:"
      if letter_count[char] > 0
        result[i] = ":yellow_square:"
        letter_count[char] -= 1
      end
    end

    event.respond(result.join, false, nil, nil, nil, event.message)
    if guess == target.downcase
      BOT.channel(1409959696349139025).send_message("#{['After', 'With about', 'With', 'Using'].sample} #{challenge.reload.end_time} guesses, **#{tribe.name}** guessed a word correctly! #{(challenge.stage + 1)}/#{target_words.size}")
      event.respond "The word was **#{target.capitalize}**. Your team guessed it correctly!"
      if (challenge.stage + 1) >= target_words.size
        event.respond "Congratulations! Your tribe has guessed the final word chosen by the other tribe!" 
      else
        event.respond "You can now attempt to guess the next word..."
      end
      challenge.update(stage: challenge.stage + 1, end_time: 0)
    end

  end
end
