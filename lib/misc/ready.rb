class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, 'Hello, new world!')
    BOT.game = 'with preparations for a new season!'
    # row.button(style: Discordrb::Webhooks::View::BUTTON_STYLES[:success], label: "Begin Application!", custom_id: 'application_start_button')
    # Que.migrate!(version: 7)
    # TestJob.enqueue(job_options: { run_at: Time.now + 300})
    # S3.upload(File.open("audio/elim.wav"), "new_elim")
  end
end
