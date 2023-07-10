class Sunny
  BOT.command(:apply) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Thanks for deciding to apply!'
      embed.description = "You'll be asked a few questions to best understand you and decide how to move on from where.\nFirst things first, what will be your name, age, timezone and pronouns? Answer what you're comfortable with."
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply1` to move on.')
    end
  end

  BOT.command(:apply1) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 1'
      embed.description = 'Are you new to ORGs or a seasoned veterans? How does your history look like?'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply2` to move on.')
    end
  end

  BOT.command(:apply2) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 2'
      embed.description = 'Do you have a defined playstyle or do you just deal with things as they go? Tell us about your play!'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply3` to move on.')
    end
  end
  
  BOT.command(:apply3) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 3'
      embed.description = 'In a game like Survivor, alliances and social dynamics play a crucial role. How would you approach forming alliances and building relationships with other players?'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply4` to move on.')
    end
  end
  
  BOT.command(:apply4) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 4'
      embed.description = 'Imagine you are faced with a difficult decision that may benefit you in the game but potentially destroy your reputation. How would you approach it?'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply5` to move on.')
    end
  end
  
  BOT.command(:apply5) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 5'
      embed.description = 'How do you deal with uncertainty and unpredictable situations? Are you comfortable taking risks, or do you prefer a more cautious approach?'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply6` to move on.')
    end
  end

  BOT.command(:apply6) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 6'
      embed.description = 'How do you deal with uncertainty and unpredictable situations? Are you comfortable taking risks, or do you prefer a more cautious approach?'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply7` to move on.')
    end
  end

  BOT.command(:apply7) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 7'
      embed.description = 'Who are you? What are your hobbies and interests? Tell us about yourself!'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply8` to move on.')
    end
  end

  BOT.command(:apply8) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 8'
      embed.description = 'In a scale of 1-10, how much engagement can we expect from you?'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!apply9` to move on.')
    end
  end
  
  BOT.command(:apply9) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Final Question'
      embed.description = 'Why did you choose to apply to Botvivor: Hard Drive?'
      embed.color = 'e7df36'
      embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: 'Use the command `!finish` to settle things.')
    end
  end

  BOT.command(:finish) do |event|
    break unless event.channel.parent == 1128056313721659423
    event.channel.send_embed do |embed|
      embed.title = 'Application Question 7'
      embed.description = "Thank you for applying! We'll mention you again for check-ins, and then see you at #{BOT.channel(1125139196420563147).mention}!"
      embed.color = 'e7df36'
    end
  end
end
