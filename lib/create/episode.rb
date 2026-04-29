class Sunny
  def self.prompt_episode_title
    return if Setting.host_chat_channel_id.zero?

    episode = current_episode
    BOT.channel(Setting.host_chat_channel_id).send_message(
      "All active Tribal Councils are complete. Set Episode #{episode.number || 1}'s title with `!episode_title @quote_owner quote text`."
    )
  rescue StandardError
    nil
  end

  def self.after_all_councils_resolved
    return unless active_councils.empty?

    prompt_episode_title
    prompt_spectator_games(BOT.channel(Setting.host_chat_channel_id)) unless Setting.host_chat_channel_id.zero?
  end

  BOT.command :episode_title do |event, *args|
    break unless event.user.id.host?

    quote = args.join(' ').strip
    owner = nil
    if event.message.mentions.any?
      owner = Player.find_by(user_id: event.message.mentions.first.id, season_id: Setting.season_id)
      quote = quote.gsub(/<@!?\d+>/, '').strip
    end

    if quote.empty?
      event.respond('Use `!episode_title @quote_owner quote text`.')
      break
    end

    episode = current_episode
    episode.title = quote
    episode[:title_owner] = owner&.id
    episode.save
    next_number = (episode.number || 1) + 1
    Episode.find_or_create_by(season_id: Setting.season_id, number: next_number)

    event.respond("Episode #{episode.number || 1} title set: \"#{quote}\"#{owner ? " — #{owner.name}" : ''}. Episode #{next_number} has begun.")
  end
end
