require 'discordrb'

bot = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], prefix: "!"

bot.run

