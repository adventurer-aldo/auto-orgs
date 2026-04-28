class Sunny
  BOT.member_join do |event|
    BOT.channel(Setting.user_join_channel_id).send_embed do |embed|
      embed.title = "#{event.user.display_name}'s time here has begun! :arrow_forward:"
      embed.description = "**Welcome to Alvivor!**\nWe're glad to have you here!\n**Season 4**'s applications are on the horizon..."
      embed.color = 'ffdf15'
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.user.avatar_url)
    end
    event.user.on(event.server).add_role(Setting.spectator_role_id)
  end

  BOT.member_leave do |event|
    BOT.channel(Setting.user_leave_channel_id).send_message(":pause_button: **#{event.user.display_name}**'s time here has paused...")
  end
end
