class Sunny

  BOT.command :to_html do |event, *args|
    event.respond(args.join(''))
    event.channel.send_file(html_to_image(args.join(' ')), filename: 'image.png')
  end
end