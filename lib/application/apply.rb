class Sunny
  BOT.command(:apply) do |event|
    break unless event.channel.parent == 1128056313721659423
    veteran = Player.where(user_id: event.user.id).exists?
    event.channel.send_embed do |embed|
      embed.title = 'Thanks for deciding to apply!'
      embed.description = "You'll be asked a few questions to best understand you and decide how when you are done from where.#{veteran ? "\nSince things *might* have changed since your last time here, we will ask just to be sure." : ''}\nFirst things first, what will be your \n**Name**\n**Age**\n**Timezone**\n**Pronouns?**\n\nAnswer what you're comfortable with."
      embed.color = '9a5cd8'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply1` when you are done.')
    end
  end

  BOT.command(:apply1) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 1'
      embed.description = "Do you believe in spirits? Why?"
      embed.color = '9a5cd8'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply2` when you are done.')
    end
  end

  BOT.command(:apply2) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 2'
      embed.description = "People who don't walk on this earth with us any longer... Where do you think they go to?"
      embed.color = '9a5cd8'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply3` when you are done.')
    end
  end
  
  BOT.command(:apply3) do |event|
    break unless event.channel.parent == 1128056313721659423
    veteran = Player.where(user_id: event.user.id).exists?
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 3'
      embed.description = "Is this your #{veteran ? 'second' : 'first'} time playing a Survivor ORG?"
      embed.color = '9a5cd8'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply4` when you are done.')
    end
  end
  
  BOT.command(:apply4) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 4'
      embed.description = 'Do you always honor your promises?'
      embed.color = '9a5cd8'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply5` when you are done.')
    end
  end
  
  BOT.command(:apply5) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 5'
      embed.description = "Imagine the following scenario:\n```You're in a team/tribe of 5, attending Tribal Council, where one of you will be voted out of the game by the tribe. Two of your tribemates are a solid duo, never-gonna-backstab-you type. The other two are... floaters. They'll do whatever as long as they don't get voted out. They're not close, even!```Which duo would you side with?"
      embed.color = '9a5cd8'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply6` when you are done.')
    end
  end

  BOT.command(:apply6) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 6'
      embed.description = "On a scale of 1-10, how active do you think you'll be?"
      embed.color = '9a5cd8'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply7` when you are done.')
    end
  end

  BOT.command(:apply7) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 7'
      embed.description = "Will you be playing other ORGs during the season? If so, how many?"
      embed.color = '9a5cd8'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply8` when you are done.')
    end
  end

  BOT.command(:apply8) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 8'
      embed.description = 'Do you have any limitations that we should be aware of? Our challenges *may* or *may not* require playing with colors or listening to certain sounds.'
      embed.color = '9a5cd8'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply9` when you are done.')
    end
  end
  
  BOT.command(:apply9) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Final Question'
      embed.description = "Lastly, any picture you'd like to represent you?"
      embed.color = '9a5cd8'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!finish` to settle things.')
    end
  end

  BOT.command(:finish) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Your application is complete!'
      embed.description = "Thank you for applying! We'd be excited to have you enjoy Alvivor!\nYou'll be mentioned again for check-ins at a later date, and then see you at #{BOT.channel(1322130194726649956).mention}!"
      embed.color = '9a5cd8'
    end
    app = Application.find_by(channel_id: event.channel.id)
    return if app.is_finished? || event.user.id != app.user_id
  
    event.user.on(event.server).add_role(1369578647962521620)
    event.user.on(event.server).remove_role(1345656680268042261)
    BOT.channel(app.channel_id).name = event.user.on(event.server).display_name + '-interview✅'
    Application.where(user_id: event.user.id).update(is_finished?: true)
    return
  end
end
