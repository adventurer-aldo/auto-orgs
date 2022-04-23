require 'discordrb'

class Augur
    BOT = Discordrb::Commands::CommandBot.new token: 'OTY2NDEyNDYzMTExMzAzMjM5.YmBXvg.RJjwvE7pDPvnR0Zl1PfekW_c2gM', prefix: "a!"

    BOT.command :s do |event, *args|
        event.respond(args.join(' '))
    end

    BOT.ready do 
        BOT.game = "The pen is mightier than the sword"
        puts "Augur"
    end

    def self.run
        puts "Running Augur"
        BOT.run :async
    end
end

Augur.run