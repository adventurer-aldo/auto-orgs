class Sunny
  TITLEWORTHY_EMOJI = 'titleworthy'

  def self.titleworthy_reaction?(emoji)
    emoji.name == TITLEWORTHY_EMOJI
  end

  def self.title_vote_content(source_message, votes)
    author = source_message.author&.distinct || source_message.author&.username || 'Unknown'
    <<~TEXT
      **#{votes} titleworthy vote#{votes == 1 ? '' : 's'}**
      #{source_message.content}

      [Jump to message](#{source_message.link})
      Submitted by #{author}
    TEXT
  end

  def self.update_episode_title_vote(event)
    return if Setting.episode_title_voting_channel_id.zero?
    return unless titleworthy_reaction?(event.emoji)

    source_message = event.message
    users = source_message.reacted_with(event.emoji, limit: nil).select { |user| spectator_user?(user) }
    votes = users.size

    title_vote = EpisodeTitleVote.find_by(source_message_id: source_message.id)
    return if title_vote && title_vote.votes == votes

    channel = BOT.channel(Setting.episode_title_voting_channel_id)
    if title_vote
      title_vote.update(votes: votes)
      posted = channel.load_message(title_vote.message_id)
      posted&.edit(title_vote_content(source_message, votes))
    elsif votes >= 3
      posted = channel.send_message(title_vote_content(source_message, votes))
      EpisodeTitleVote.create(source_message_id: source_message.id, message_id: posted.id, votes: votes)
    end
  rescue StandardError => e
    warn "Episode title vote update failed: #{e.class}: #{e.message}"
  end

  BOT.reaction_add do |event|
    update_episode_title_vote(event)
  end

  BOT.reaction_remove do |event|
    update_episode_title_vote(event)
  end
end
