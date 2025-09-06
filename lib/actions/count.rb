class Sunny
  BOT.command :tribal, description: "Changes the Tribal Council stage to 1 (after 12h) to all those who have 0." do |event|
    break unless HOSTS.include? event.user.id

    if [0, 1].include? Setting.last.game_stage
      Council.where(stage: 0).update(stage: 1)
    else
      Council.where(stage: 0).update(stage: 2)
    end
    event.respond('The tribal stage has changed.')
    return
  end

  BOT.command :tribol, description: 'Changes the Tribal Council stage to 1 (after 12h) to all those who have 0.' do |event|
    break unless HOSTS.include? event.user.id
    Council.where(stage: 2).update(stage: 1)
    event.respond('The tribal stage has changed.')
    return
  end


  BOT.command :count, description: "Counts the votes inside a Tribal Council channel." do |event|
    break unless HOSTS.include? event.user.id

    CouncilCountJob.enqueue(Council.find_by(channel_id: event.channel.id), job_options: { run_at: Time.now })
  end
end
