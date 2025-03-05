class Sunny
  BOT.member_join do |event|
    BOT.channel(USER_JOIN_CHANNEL).send_embed do |embed|
      embed.title = "#{event.user.name} has joined Alvivor! :tada: "
      embed.description = "Welcome! We hope you enjoy your stay here.\nSeason 2 is just around the corner!"
      embed.color = '6944b9'
      embed.image = Discordrb::Webhooks::EmbedThumbnail.new(url: event.user.avatar_url)
    end
  end

  BOT.member_leave do |event|
    BOT.channel(USER_LEAVE_CHANNEL).send_message("**#{event.user.name}** has just left the jungle...")
  end
end