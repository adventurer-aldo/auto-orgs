require 'discordrb'

BOT = Discordrb::Commands::CommandBot.new token: 'OTY2NDEzMzM3NzM2OTI5Mjgx.YmBYjg.9nRivsLnlLHG9xE7vNxOZsjoH3E', prefix: "p!"

BOT.command :say do |event, *args|
    event.respond(args.join(' '))
end

BOT.ready do 
    BOT.game = "Princess Precure...right? lol"
    puts "Petra"
end

BOT.run