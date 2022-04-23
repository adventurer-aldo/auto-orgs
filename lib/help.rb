class Sunny

    BOT.command :help do |event|
        event.channel.send_embed do |embed|
            embed.title = "All commands"
            embed.description = "Stuff"
        end
        
    end

end