class Sunny

    BOT.command :help do |event|
        break unless event.user.id.player?

        fields = [
            ['!alliance', 'Make an alliance with other players from your tribe.'],
            ['!rename', 'Rename an alliance to whatever you choose.'],
            ['!inventory', "Check your items and who you're voting during Tribal Council."],
            ['!play CODE', "Play an item from your inventory, where CODE is the item's code."],
            ['!give CODE', "Give an item from your inventory to any other player in the game, where CODE is the item's code."],
            ['!vote', 'Use during Tribal Council to vote another player participating in it.'],
            ['!coinflip', 'Randomly get between Heads or Tails.']
        ].map { |array| Discordrb::Webhooks::EmbedField.new(name: array[0], value: array[1]) }

        event.channel.send_embed do |embed|
            embed.title = 'All commands'
            embed.description = 'Stuff'
            embed.fields = fields
        end
        
    end

end