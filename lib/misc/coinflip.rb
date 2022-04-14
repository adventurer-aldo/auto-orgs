class Sunny

    BOT.command(:coinflip) do |event|
        event.respond('**' + ['Heads!','Tails!'].sample + '**')
    end
    
end