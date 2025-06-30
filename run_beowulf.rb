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

Beowulf.run
