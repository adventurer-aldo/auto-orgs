class Sunny

    BOT.command :rand_time do |event|
        event.respond('The timer has started!')
        sleep(rand(30..100))
        event.respond("Time's up!")
    end

end