class Sunny
  BOT.button(custom_id: 'application_start_button') do |event|
    event.defer_update
    if Application.where(user_id: event.user.id).exists?
      event.send_message(content: "You already started your application! Check <##{Application.find_by(user_id: event.user.id).channel_id}>.", ephemeral: true)
    else
      display_name = event.user.on(event.server.id).display_name
      perms = [DENY_EVERY_SPECTATE, Discordrb::Overwrite.new(event.user.id, type: 'member', allow: 3072)]
      new_application = Application.create(user_id: event.user.id, channel_id: event.server.create_channel(display_name + '-interview✍', parent: APPLICATIONS,
      topic: "#{display_name}'s application. Your adventure in Alvivor starts here!", permission_overwrites: perms).id)

      event.send_message(content: "Your application has begun! Go to <##{new_application.channel_id}> for more details.", ephemeral: true)
      BOT.channel(new_application.channel_id).send_message("Welcome #{event.user.mention}!\nThis is where you'll be writing your application for Alvivor Season 2: Animals.\nOur ORG's goal is to provide an enjoyable experience for all its participants, so take the time you need with your applications, and feel free to ask any questions you'd like!\n\nWhenever you're ready to start, write `!apply`")
      event.user.on(event.server).add_role(1345656680268042261)
    end
  end

end
