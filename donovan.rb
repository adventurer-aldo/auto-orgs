require 'discordrb'

BOT = Discordrb::Commands::CommandBot.new token: 'OTY2NDE3ODI3ODE0ODU0NzQ2.YmBcvQ.EMGIV5Ez2D5LUZOZtfV0wwfq4SA', prefix: "d!"

BOT.command :say do |event, *args|
    event.respond(args.join(' '))
end

BOT.ready do 
    BOT.game = "my balls"
    puts "Donovan"
end

BOT.run