class Sunny
  BOT.member_join do |event|
    BOT.channel(USER_JOIN_CHANNEL).send_embed do |embed|
      embed.title = "#{event.user.display_name} has joined Alvivor! :tada: "
      embed.description = "Welcome! **Season 2: Animals** just ended, but we hope you stick around while our next season is in the works!"
      embed.color = '6944b9'
      embed.thumbnail = Discordrb::Webhooks::EmbedThumbnail.new(url: event.user.avatar_url)
    end
    event.user.on(event.server).add_role(1113168262461673532)
  end

  BOT.member_leave do |event|
    BOT.channel(USER_LEAVE_CHANNEL).send_message("**#{event.user.display_name}** has just left...")
  end
end