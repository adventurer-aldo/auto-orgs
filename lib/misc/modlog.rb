class Sunny
  def self.modlog_block(content)
    text = content.to_s
    text = '(empty message)' if text.empty?
    text = text.gsub('```', "'''")
    text = "#{text[0...950]}..." if text.length > 950
    "```\n#{text}\n```"
  end

  def self.modlog_channel_name(channel)
    channel ? "##{channel.name}" : '#unknown-channel'
  end

  def self.modlog_user_info(user)
    {
      name: user.respond_to?(:display_name) ? user.display_name : user.name,
      avatar_url: user.avatar_url
    }
  end

  def self.modlog_message_authors
    @modlog_message_authors ||= {}
  end

  def self.modlog_author(message_id, user)
    modlog_message_authors[message_id] = modlog_user_info(user)
  end

  def self.modlog_embed_author(info)
    return if info.nil?

    Discordrb::Webhooks::EmbedAuthor.new(name: info[:name], icon_url: info[:avatar_url])
  end

  BOT.message do |event|
    next if event.from_bot?

    modlog_author(event.message.id, event.user)

    message = Message.find_or_initialize_by(message_id: event.message.id)
    message.update(content: event.content, channel_id: event.channel.id)
  end

  BOT.message_edit do |event|
    next if event.from_bot?

    author = modlog_author(event.message.id, event.user)
    message = Message.find_or_initialize_by(message_id: event.message.id)
    old_content = message.content
    new_content = event.content

    BOT.channel(MODLOG_CHANNEL).send_embed do |embed|
      embed.title = 'Message Edited'
      embed.author = modlog_embed_author(author)
      embed.description = "Channel: #{modlog_channel_name(event.channel)}"
      embed.add_field(name: 'Before', value: modlog_block(old_content))
      embed.add_field(name: 'After', value: modlog_block(new_content))
      embed.color = '#f0ad4e'
    end

    message.update(content: new_content, channel_id: event.channel.id)
  end

  BOT.message_delete do |event|
    message = Message.find_by(message_id: event.id)
    author = modlog_message_authors.delete(event.id)
    content = message&.content

    BOT.channel(MODLOG_CHANNEL).send_embed do |embed|
      embed.title = 'Message Deleted'
      embed.author = modlog_embed_author(author)
      embed.description = "Channel: #{modlog_channel_name(event.channel)}"
      embed.add_field(name: 'Content', value: modlog_block(content))
      embed.color = '#d9534f'
    end

    message&.destroy
  end
end
