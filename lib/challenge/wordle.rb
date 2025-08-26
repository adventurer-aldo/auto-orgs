class Sunny

  WORDLE = File.open('./lib/create/merge_cheers.txt', 'r').readlines

  BOT.command :word do |event, *args|
    word = args.join('').downcase
    if WORDLE.include? word
      event.respond "Yeah that word exists in wordle"
    else
      event.respond "Nah, that word ain't exist in wordle"
    end
  end
end
