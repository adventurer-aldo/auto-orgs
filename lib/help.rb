class Sunny
  BOT.command :help do |event|
    break unless event.user.id.player? || event.user.id.host?

    fields = [
        ['!alliance', 'Make an alliance with other players from your tribe.'],
        ['!rename', 'Rename an alliance to whatever you choose.'],
        ['!buddy', 'Allow a trusted spectator to chat with you in your confessional channel.'],
        ['!unbuddy', 'Stops a trusted spectator from being able to chat in your confessional channel.'],
        ['!inventory', "Check your items and who you're voting during Tribal Council."],
        ['!play CODE', "Play an item from your inventory, where CODE is the item's code."],
        ['!give CODE', "Give an item from your inventory to any other player in the game, where CODE is the item's code."],
        ['!vote', 'Use during Tribal Council to vote another player participating in it.'],
        ['!coinflip', 'Randomly get between Heads or Tails.']
    ].map { |array| Discordrb::Webhooks::EmbedField.new(name: array[0], value: array[1]) }

    event.channel.send_embed do |embed|
      embed.title = 'All general commands'
      embed.description = 'You can use these any time regardless of the stage of the game.'
      embed.fields = fields
      embed.color = event.user.on(event.server).color
    end
  end
end
