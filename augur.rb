require 'discordrb'

BOT = Discordrb::Commands::CommandBot.new token: 'OTY2NDEyNDYzMTExMzAzMjM5.YmBXvg.RJjwvE7pDPvnR0Zl1PfekW_c2gM', prefix: "a!"

BOT.command :say do |event, *args|
    event.respond(args.join(' '))
end

BOT.ready do 
    BOT.game = "The pen is mightier than the sword"
    puts "Augur"
end

BOT.run