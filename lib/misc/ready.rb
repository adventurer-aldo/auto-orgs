class Sunny
  BOT.ready do
    BOT.send_message(HOST_CHAT, 'Hello, world!')
    BOT.game = 'Alvivor Season 2!'
    # row.button(style: Discordrb::Webhooks::View::BUTTON_STYLES[:success], label: "Begin Application!", custom_id: 'application_start_button')
    # Que.migrate!(version: 7)
    TestJob.enqueue
    # S3.upload(File.open("audio/elim.wav"), "new_elim")
  end
end
