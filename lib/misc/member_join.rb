class Sunny
  BOT.member_join do |event|
    BOT.channel(USER_JOIN_CHANNEL).send_embed do |embed|
      embed.title = "#{event.user.display_name}'s time here has begun! :arrow_forward:"
      embed.description = "**Welcome to Alvivor!**\nWe're glad to have you here!\n**Season 4**'s applications are on the horizon..."
      embed.color = 'ffdf15'
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.user.avatar_url)
    end
    event.user.on(event.server).add_role(1113168262461673532)
  end

  BOT.member_leave do |event|
    BOT.channel(USER_LEAVE_CHANNEL).send_message(":pause_button: **#{event.user.display_name}**'s time here has paused...")
  end
end