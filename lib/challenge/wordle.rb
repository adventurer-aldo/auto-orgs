class Sunny
  @wordles = File.readlines('./lib/challenge/wordles.txt', chomp: true)
  @guessles = File.readlines('./lib/challenge/guessles.txt', chomp: true)

  # Pick a random target word at start
  @target = @wordles.sample

  BOT.command :word do |event, *args|
    guess = args.join('').downcase

    # validate
    unless (@wordles + @guessles).include?(guess)
      event.respond "Not a valid word!"
      next
    end

    # compare guess vs target
    result = []
    target_chars = @target.chars
    guess.chars.each_with_index do |char, i|
      if char == target_chars[i]
        result << ":green_square:"
      elsif target_chars.include?(char)
        result << ":yellow_square:"
      else
        result << ":white_large_square:"
      end
    end

    event.respond result.join
    event.respond "Target: #{@target}" if guess == @target
  end
end
