class Sunny
  @wordles = File.readlines('./lib/challenge/wordles.txt', chomp: true)
  @guessles = File.readlines('./lib/challenge/guessles.txt', chomp: true)

  @target = @wordles.sample

  BOT.message(in: 1378044547287879731) do |event|
    guess = event.message.content.downcase

    unless (@wordles + @guessles).include?(guess)
      puts "Someone guessed wordle incorrectly...."
      next
    end

    result = Array.new(guess.length, ":white_large_square:")
    target_chars = @target.chars
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
    event.respond "Target: #{@target}" if guess == @target
  end
end
