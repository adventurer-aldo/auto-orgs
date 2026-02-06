class Sunny
  def self.application_thing
    view = Discordrb::Webhooks::View.new
    view.row { |row| row.button(custom_id: "application_start_button", label: "🍊 Start Application", style: 3) }
    embed = Discordrb::Webhooks::Embed.new
    embed.title = "Applications for Alvivor Season 4: Fruits"
    embed.description = "Alumni and newbies are allowed to apply to become one of **16 Castaways**. \nNewbies and alumni who haven't played more than 1 season will be given priority.\n\nClick the button below to begin your application!"
    embed.color = "2A388A"
    BOT.channel(1128055783519686756).send_message("", false, embed, nil, nil, nil, view)
  end

  BOT.button(custom_id: 'application_start_button') do |event|
    event.defer_update
    if Application.where(user_id: event.user.id).exists?
      event.send_message(content: "You already started your application! Check <##{Application.find_by(user_id: event.user.id).channel_id}>.", ephemeral: true)
    else
      display_name = event.user.on(event.server.id).display_name
      perms = [DENY_EVERY_SPECTATE, Discordrb::Overwrite.new(event.user.id, type: 'member', allow: 3072)]
      veteran = Player.where(user_id: event.user.id).exists?
      new_application = Application.create(user_id: event.user.id, channel_id: event.server.create_channel(display_name + '-interview✍', parent: APPLICATIONS,
      topic: "#{display_name}'s application. Your adventure in Alvivor #{veteran ? 'continues' : 'starts'} here!", permission_overwrites: perms).id)

      event.send_message(content: "Your application has begun! Go to <##{new_application.channel_id}> for more details.", ephemeral: true)
      BOT.channel(new_application.channel_id).send_message("Welcome#{veteran ? ' back' : ''} #{event.user.mention}!\nThis is where you'll be writing your application for Alvivor Season 4: Fruits.\n#{veteran ? "The process is mostly the same as last season's, so you'll have no problem filling it out!\n" : ''}Our ORG's goal is to provide an enjoyable experience for all its participants, so take the time you need with your applications, and feel free to ask any questions you'd like!\n\nWhenever you're ready to start, write `!apply`")
      event.user.on(event.server).add_role(1345656680268042261)
    end
  end

end
