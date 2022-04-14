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
    end
end

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
require_relative 'settings'
require_all 'lib'

Sunny.run

