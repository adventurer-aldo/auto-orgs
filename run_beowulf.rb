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

@tokens.keys.each do |key|
  bot = Discordrb::Commands::CommandBot.new token: @tokens[key], prefix: '?'
  
  bot.ready do |event|
    bot.game = "Alvivor S3: Spirits & Souls"
  end

  bot.run true
end

# Beowulf.run
