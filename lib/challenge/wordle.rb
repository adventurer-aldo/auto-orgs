class Sunny
  @wordles = File.readlines('./lib/challenge/wordles.txt', chomp: true)
  @guessles = File.readlines('./lib/challenge/guessles.txt', chomp: true)
  @stage = 0
  @uada_id = 25
  @habiti_id = 26
  
  @uada_words = ['epoch', 'trite', 'quoth', 'wooer', 'mango', 'buxom']

  
  BOT.message(in: 1378044547287879731) do |event|
    return if @stage > 5
    target = @uada_words[@stage]
    
    guess = event.message.content.downcase

    unless (@wordles + @guessles).include?(guess)
      puts "Someone guessed wordle incorrectly...."
      next
    end

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

    event.respond result.join
    if guess == target
      event.respond "The word was #{target}. You correctly guessed it!\n\nA new word is up for guessing..."
      @stage += 1
      event.respond "You're done." if @stage > 5
    end

  end
end
