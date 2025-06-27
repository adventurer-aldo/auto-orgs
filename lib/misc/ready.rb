class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, 'Hello, world!')
    BOT.game = 'Alvivor Season 2!'
    # Player.where(name: ['Corrin', 'chess', 'dani', 'Schulz']).each { |player| player.individuals.create(stage: 6) }
    # row.button(style: Discordrb::Webhooks::View::BUTTON_STYLES[:success], label: "Begin Application!", custom_id: 'application_start_button')
    # Que.migrate!(version: 7)
    # TestJob.enqueue(job_options: { run_at: Time.new(2025, 6, 27, 15, 0, 0) })
    # TestJob.enqueue(job_options: { run_at: Time.now + 300})
    # S3.upload(File.open("audio/elim.wav"), "new_elim")
  end
end
