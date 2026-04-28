class Sunny
  def self.modlog_block(content)
    text = content.to_s
    text = '(empty message)' if text.empty?
    text = text.gsub('```', "'''")
    text = "#{text[0...950]}..." if text.length > 950
    "```\n#{text}\n```"
  end

  BOT.message do |event|
    next if event.from_bot?

    message = Message.find_or_initialize_by(message_id: event.message.id)
    message.update(content: event.content, channel_id: event.channel.id)
  end

  BOT.message_edit do |event|
    next if event.from_bot?

    message = Message.find_or_initialize_by(message_id: event.message.id)
    old_content = message.content
    new_content = event.content

    BOT.channel(MODLOG_CHANNEL).send_embed do |embed|
      embed.title = 'Message Edited'
      embed.description = "Channel: <##{event.channel.id}>\nMessage ID: #{event.message.id}"
      embed.add_field(name: 'Before', value: modlog_block(old_content))
      embed.add_field(name: 'After', value: modlog_block(new_content))
      embed.color = '#f0ad4e'
    end

    message.update(content: new_content, channel_id: event.channel.id)
  end

  BOT.message_delete do |event|
    message = Message.find_by(message_id: event.id)
    content = message&.content

    BOT.channel(MODLOG_CHANNEL).send_embed do |embed|
      embed.title = 'Message Deleted'
      embed.description = "Channel: <##{event.channel.id}>\nMessage ID: #{event.id}"
      embed.add_field(name: 'Content', value: modlog_block(content))
      embed.color = '#d9534f'
    end

    message&.destroy
  end
end
