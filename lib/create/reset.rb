class Sunny
  BOT.command :prune, description: 'Cleans up a channel.' do |event|
    break unless event.user.id.host?

    event.channel.prune(100)
    return
  end

  BOT.command :update, description: 'Updates the item list so that new codes can be found.' do |event|
    break unless event.user.id.host?

    make_item_commands
    event.respond('The items list has been updated!')
  end
end
