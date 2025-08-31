class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, '# <a:torch:1400359863393062952> Hello, new world! <a:torch:1400359863393062952>')
    BOT.game = 'Season 3: Spirits & Souls!'
    InServerStats.enqueue(job_options: {run_at: Time.now})
    WorshipUpdateJob.enqueue(job_options: {run_at: Time.now})
  end
end
