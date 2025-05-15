class Sunny
  BOT.command(:apply) do |event|
    break unless event.channel.parent == 1128056313721659423
    veteran = Player.where(user_id: event.user.id).exists?
    event.channel.send_embed do |embed|
      embed.title = 'Thanks for deciding to apply!'
      embed.description = "You'll be asked a few questions to best understand you and decide how when you are done from where.#{veteran ? "\nSince things *might* have changed since your last time here, we will ask just to be sure." : ''}\nFirst things first, what will be your \n**Name**\n**Age**\n**Timezone**\n**Pronouns?**\n\nAnswer what you're comfortable with."
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply1` when you are done.')
    end
  end

  BOT.command(:apply1) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 1'
      embed.description = "What's your favorite animal, and why?"
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply2` when you are done.')
    end
  end

  BOT.command(:apply2) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 2'
      embed.description = 'If you had to classify yourself as either a Hero or a Villain, which would you go with?'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply3` when you are done.')
    end
  end
  
  BOT.command(:apply3) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 3'
      embed.description = 'Not just in a game like Survivor, but also in real life and in the wildlife, having relationships can make improve your chances drastically. How would you go about forming relationships with other players in this season?'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply4` when you are done.')
    end
  end
  
  BOT.command(:apply4) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 4'
      embed.description = 'Imagine you are faced with a difficult decision that may benefit you in the game but potentially destroy your reputation. How would you approach it?'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply5` when you are done.')
    end
  end
  
  BOT.command(:apply5) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 5'
      embed.description = 'How do you deal with uncertainty and unpredictable situations? Are you comfortable taking risks, or do you prefer a more cautious approach?'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply6` when you are done.')
    end
  end

  BOT.command(:apply6) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 6'
      embed.description = 'Who are you? What are your hobbies and interests? Tell us about yourself!'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply7` when you are done.')
    end
  end

  BOT.command(:apply7) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 7'
      embed.description = 'In a scale of 1-10, how much engagement can we expect from you?'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply8` when you are done.')
    end
  end

  BOT.command(:apply8) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 8'
      embed.description = 'What picture would you like to be represented with?'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply9` when you are done.')
    end
  end
  
  BOT.command(:apply9) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Final Question'
      embed.description = "Why did you choose to apply to Alvivor Season 2: Animals?\nThe answer won't impact anything, we're just curious!"
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!finish` to settle things.')
    end
  end

  BOT.command(:finish) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Your application is complete!'
      embed.description = "Thank you for applying! We'd be excited to have you enjoy Alvivor!\nYou'll be mentioned again for check-ins at a later date, and then see you at #{BOT.channel(1322130194726649956).mention}!"
      embed.color = 'e7df36'
    end
    app = Application.find_by(channel_id: event.channel.id)
    return if app.is_finished || event.user.id != app.user_id
  
    event.user.on(event.server).add_role(1369578647962521620)
    event.user.on(event.server).remove_role(1345656680268042261)
    BOT.channel(app.channel_id).name = event.user.on(event.server).display_name + '-interview✅'
    Application.where(user_id: event.user.id).update(is_finished: true)
    return
  end
end
