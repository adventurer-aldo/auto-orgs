class Sunny
  BOT.command :season_timer do |event|
    break unless event.user.id.host?
    a = Season.last
    a.update(start_time: Time.now)
    InServerStats.enqueue(job_options: {run_at: Time.now})
  end
end
