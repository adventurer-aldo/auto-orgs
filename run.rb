require 'active_record'
require 'discordrb'
require 'dotenv'
require 'open-uri'
require 'pg'
require 'require_all'

Dotenv.load

class Sunny
    BOT = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], prefix: '!'

    def self.run
        BOT.run
        puts 'Sunny Go!'
    end

end

ActiveRecord::Base.establish_connection(ENV['DATABASE_URL'])
require_relative 'settings'
require_all 'models'
require_all 'lib'

Sunny.run