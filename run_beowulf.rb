require 'discordrb'
require 'dotenv'

Dotenv.load

class Beowulf
  BOT = Discordrb::Commands::CommandBot.new token: ENV['BEOWULF_TOKEN'], prefix: '?'

  BOT.ready do |event|
    BOT.game = "Watching the pack..."
  end

  def self.run
    puts 'Beowulf Go!'
    BOT.run false
  end
end

@tokens = {
  stew: ENV['ONE'],
  lynn: ENV['TWO'],
  isaiah: ENV['THREE'],
  idan: ENV['FOUR'],
  emerald: ENV['FIVE'],
  tabi: ENV['SIX']
}

bot = Discordrb::Commands::CommandBot.new token: ENV[ENV['CHOSEN']], prefix: '?'

bot.ready do |event|
  bot.dnd
end

bot.dm do |event|
  bot.channel(1378044547287879731).send_message event.message.content
end

bot.run false
# Beowulf.run
