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

  def self.modlog_time(time)
    return 'Unknown' if time.nil?

    "<t:#{time.to_i}:f>"
  end

  def self.modlog_user_info(user)
    {
      id: user.id,
      name: user.respond_to?(:display_name) ? user.display_name : user.name,
      avatar_url: user.avatar_url
    }
  end

  def self.modlog_message_cache
    @modlog_message_cache ||= {}
  end

  def self.modlog_spam_deletes
    @modlog_spam_deletes ||= {}
  end

  def self.modlog_suspicious_mentions?(event)
    content = event.content.to_s
    raw_mentions = content.scan(/<@!?\d+>|<@&\d+>/).size
    mention_count = event.message.mentions.size + event.message.role_mentions.size

    content.include?('@everyone') || content.include?('@here') || raw_mentions > 1 || mention_count > 1
  end

  def self.modlog_cache_message(event)
    existing = modlog_message_cache[event.message.id] || {}
    modlog_message_cache[event.message.id] = {
      author: modlog_user_info(event.user),
      suspicious_mentions: modlog_suspicious_mentions?(event),
      timestamp: existing[:timestamp] || event.timestamp || Time.now,
      edited_timestamp: existing[:edited_timestamp],
      cached_at: existing[:cached_at] || Time.now
    }
  end

  def self.modlog_embed_author(info)
    return if info.nil?

    Discordrb::Webhooks::EmbedAuthor.new(name: info[:name], icon_url: info[:avatar_url])
  end

  def self.modlog_spam_delete_count(message_info)
    return 0 unless message_info&.dig(:suspicious_mentions)

    user_id = message_info.dig(:author, :id)
    return 0 if user_id.nil?

    now = Time.now
    recent = (modlog_spam_deletes[user_id] || []).select { |deleted_at| now - deleted_at < 60 }
    recent << now
    modlog_spam_deletes[user_id] = recent

    recent.size
  end

  BOT.message do |event|
    next if event.from_bot?

    modlog_cache_message(event)

    message = Message.find_or_initialize_by(message_id: event.message.id)
    message.update(
      content: event.content,
      channel_id: event.channel.id,
      timestamp: event.timestamp || Time.now
    )
  end

  BOT.message_edit do |event|
    next if event.from_bot?

    modlog_cache_message(event)
    author = modlog_message_cache[event.message.id][:author]
    message = Message.find_or_initialize_by(message_id: event.message.id)
    old_content = message.content
    new_content = event.content
    created_at = message.timestamp || modlog_message_cache[event.message.id][:timestamp]
    edited_at = Time.now
    modlog_message_cache[event.message.id][:edited_timestamp] = edited_at

    BOT.channel(MODLOG_CHANNEL).send_embed do |embed|
      embed.title = 'Message Edited'
      embed.author = modlog_embed_author(author)
      embed.description = "Channel: #{modlog_channel_name(event.channel)}"
      embed.add_field(name: 'Before', value: modlog_block(old_content))
      embed.add_field(name: 'After', value: modlog_block(new_content))
      embed.add_field(name: 'Sent', value: modlog_time(created_at), inline: true)
      embed.add_field(name: 'Edited', value: modlog_time(edited_at), inline: true)
      embed.color = '#f0ad4e'
    end

    message.update(
      content: new_content,
      channel_id: event.channel.id,
      timestamp: created_at || event.timestamp || Time.now,
      edited_timestamp: edited_at
    )
  end

  BOT.message_delete do |event|
    message = Message.find_by(message_id: event.id)
    message_info = modlog_message_cache.delete(event.id)
    author = message_info&.dig(:author)
    content = message&.content
    created_at = message&.timestamp || message_info&.dig(:timestamp)
    edited_at = message&.edited_timestamp || message_info&.dig(:edited_timestamp)
    deleted_at = Time.now
    spam_delete_count = modlog_spam_delete_count(message_info)

    if spam_delete_count == 3
      BOT.channel(MODLOG_CHANNEL).send_embed do |embed|
        embed.title = 'Possible Mention Spam Deleted'
        embed.author = modlog_embed_author(author)
        embed.description = "Channel: #{modlog_channel_name(event.channel)}"
        embed.add_field(name: 'Note', value: 'Multiple deleted messages from this user had @everyone, @here, or multiple mentions. Further similar deletes are being suppressed briefly.')
        embed.add_field(name: 'Deleted', value: modlog_time(deleted_at), inline: true)
        embed.color = '#d9534f'
      end
    end

    if spam_delete_count > 2
      message&.destroy
      next
    end

    BOT.channel(MODLOG_CHANNEL).send_embed do |embed|
      embed.title = 'Message Deleted'
      embed.author = modlog_embed_author(author)
      embed.description = "Channel: #{modlog_channel_name(event.channel)}"
      embed.add_field(name: 'Content', value: modlog_block(content))
      embed.add_field(name: 'Sent', value: modlog_time(created_at), inline: true)
      embed.add_field(name: 'Last Edited', value: modlog_time(edited_at), inline: true) if edited_at
      embed.add_field(name: 'Deleted', value: modlog_time(deleted_at), inline: true)
      embed.color = '#d9534f'
    end

    message&.destroy
  end
end
