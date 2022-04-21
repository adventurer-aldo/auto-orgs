class Sunny

    BOT.command(:coinflip, description: "Randomly get Heads or Tails.") do |event|
        event.respond('**' + ['Heads!','Tails!'].sample + '**')
    end
    
end