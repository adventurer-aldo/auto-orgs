class Sunny 

    BOT.command :alliance, description: "Make an alliance with other players on your tribe." do |event, *args|
        player = Player.find_by(user_id: event.user.id, season: Setting.last.season, status: ALIVE)
        tribe = Tribe.find_by(id: player.tribe)
        if event.user.id.player? && event.server.role(tribe.role_id).members.size > 3
            enemies = Player.where(tribe: tribe.id, season: Setting.last.season, status: ALIVE).excluding(Player.where(id: player.id))
            options = enemies.map(&:id)
            options_text = enemies.map(&:name)
            text = []

            enemies.each do |enemy|
                text << "**#{enemy.id}** — #{enemy.name}"
            end

            choices = []
            if args.size > 0
                choices = args
            else
                event.channel.send_embed do |embed|
                    embed.title = "Who would you like to make an alliance with?"
                    embed.description = text.join("\n")
                    embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "Use the numbers for better accuracy.")
                    embed.color = event.server.role(tribe.role_id).color
                end
                event.user.await!(timeout: 100) do |await|
                    choices = await.message.content.split(' ')
                    true
                end

            end


            choices.map! do |option|
                if option.to_i == 0
                    query = options_text.filter { |n| n.downcase.include? option.downcase }
                    query = query.first
                    if query == nil
                        nil
                    else
                        options[options_text.index(query)]
                    end
                else
                    options.filter { |n| n == option.to_i }.first
                end
            end
            choices.uniq!
            choices.delete(nil)

            event.respond("There were no matches.") if choices.size == 0
            break if choices.size == 0

            event.respond("Not enough members for an alliance!") if choices.size < 2
            break if choices.size < 2

            choices.map! do |choice|
                Player.find_by(id: choice)
            end
            event.respond("**You're about to make an alliance with #{choices.map(&:name).join(', ')}. Are you sure?**")
            event.user.await!(timeout: 70) do |await|
                case await.message.content.downcase
                when 'yes', 'yeah', 'yeh', 'yuh', 'yup', 'y','ye','heck yeah','yep','yessir','indeed','yessey','yess'
                    rank = Player.where(season: Setting.last.season, status: ALIVE).size
                    begin
                        choices << player
                        choices.sort_by!(&:id)
                        raise ActiveRecord::RecordNotUnique if Alliance.where(players: choices.map(&:id)).exists?
                        perms = [TRUE_SPECTATE, DENY_EVERY]
                        choices.each do |n| 
                            perms << Discordrb::Overwrite.new(n.user_id, type: 'member', allow: 3072) 
                        end

                        alliance = Alliance.create(players: choices.map(&:id), channel_id: event.server.create_channel(
                            choices.map(&:name).join('-'),
                            parent: ALLIANCES,
                            topic: "Created at F#{rank} by **#{player.name}**. | #{choices.map(&:name).join('-')}",
                            permission_overwrites: perms
                        ).id)
                        BOT.send_message(alliance.channel_id, "#{event.server.role(tribe.role_id).mention}")
                        event.respond("**Your alliance is done! Check out #{BOT.channel(alliance.channel_id).mention}**")
                    rescue ActiveRecord::RecordNotUnique
                        event.respond("**This alliance already exists!**")
                    end
                when 'no','nah','nop','nay','noo','nope','nuh uh','nuh','nuh-uh'
                    event.respond("Okay!")
                else
                    event.respond("Sorry, I didn't quite understand what you said. Can you start all over?")
                end
                true
            end
            return
        end
    end

end