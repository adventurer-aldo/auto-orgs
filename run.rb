require 'active_record'
require 'discordrb'
require 'dotenv'
require 'pg'
require 'require_all'

Dotenv.load

class Sunny
    BOT = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], prefix: "!"

    def self.run
        BOT.run
        puts "Sunny Go!"
    end

end

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
require_relative 'settings'
require_relative 'petra'
require_relative 'donovan'
require_relative 'sailor'
require_relative 'augur'
require_all 'lib'

Augur.run
Donovan.run
Petra.run
Sailor.run
Sunny.run

