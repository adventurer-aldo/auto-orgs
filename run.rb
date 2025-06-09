require 'active_record'
require 'discordrb'
require 'dotenv'
require 'open-uri'
require 'pg'
require 'que'
require 'require_all'

Dotenv.load

class Sunny
  BOT = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], prefix: '!'
  #S3 = Shrine::Storage::S3.new(
  #  bucket: ENV['B2_BUCKET'], # required
  #  region: ENV['B2_REGION'], # required
  #  access_key_id: ENV['B2_KEY_ID'],
  #  secret_access_key: ENV['B2_APPLICATION_KEY'],
  #  endpoint: 'https://s3.us-west-004.backblazeb2.com',
  #  public: true
  #)

  def self.run
    puts 'Sunny Go!'
    BOT.run true
  end
end

ActiveRecord::Base.establish_connection(ENV['DB'])
Que.connection = ActiveRecord
require_relative 'settings'
require_all 'models'
require_all 'lib'

Sunny.run
