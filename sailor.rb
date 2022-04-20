require 'discordrb'

BOT = Discordrb::Commands::CommandBot.new token: 'OTY2NDE0ODgzNzE5NjIyNzM2.YmBZ_w.sPgYSdCK2ARoIxem7iiFD9jH-BU', prefix: "s!"

BOT.command :say do |event, *args|
    event.respond(args.join(' '))
end

BOT.ready do 
    BOT.dnd
    puts "Sailor"
end

BOT.run