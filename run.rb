require 'active_record'
require 'base64'
require 'discordrb'
require 'dotenv'
require "mini_magick"
require 'open-uri'
require 'pg'
require 'que'
require "json"
require 'shrine'
require "net/http"
require 'require_all'
require 'que/active_record/model'

class QueJob < Que::ActiveRecord::Model
end
Dotenv.load

class Sunny
  BOT = Discordrb::Commands::CommandBot.new token: ENV['TOKEN'], prefix: '!'

  HTML_TO_PNG = URI("https://api.doppio.sh/v1/render/screenshot/sync")
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

# Initialize Storage system
Shrine.plugin :determine_mime_type, analyzer: :file

auth_str = Base64.strict_encode64("#{ENV['AWS_ACCESS_KEY_ID']}:#{ENV['AWS_SECRET_ACCESS_KEY']}")
uri = URI("https://api.backblazeb2.com/b2api/v2/b2_authorize_account")
req = Net::HTTP::Get.new(uri)
req["Authorization"] = "Basic #{auth_str}"
res = Net::HTTP.start(uri.host, uri.port, use_ssl: true) { |http| http.request(req) }
data = JSON.parse(res.body)

Shrine.storages = {
  store: Shrine::Storage::B2Native.new(
    bucket_id: ENV['AWS_BUCKET_ID'], auth_token: data["authorizationToken"], api_url: ENV['AWS_API_URL'], bucket_name: ENV['AWS_BUCKET_NAME'], region: ENV['AWS_REGION']
  )
}

Sunny.run
