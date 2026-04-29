class Sunny
  BOT.command :count, description: "Counts the votes inside a Tribal Council channel." do |event|
    break unless event.user.id.host?

    event.message.delete
    CouncilCountJob.enqueue(Council.find_by(channel_id: event.channel.id).id, job_options: { run_at: Time.now })
    return
  end
end
