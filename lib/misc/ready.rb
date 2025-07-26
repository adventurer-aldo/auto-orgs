class Sunny
target = BOT.channel(1378044547287879731)
  BOT.ready do |event|
    [1397578244760404049].each do |category|
      target.send_message("Starting off with the **#{BOT.channel(category).name}** category...")
      BOT.channel(category).children.each do |child|
        child.permission_overwrites = [Discordrb::Overwrite.new(1397576481106034719, type: 'role', allow: 1088, deny: 2048),
        Discordrb::Overwrite.new(1113165917870895256, allow: 0, deny: 3136)]
        target.send_message("Done archiving **#{child.name}** properly.")
        sleep(100)
      end
    end
  end
end
