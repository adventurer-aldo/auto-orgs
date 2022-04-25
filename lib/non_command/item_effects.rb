class Sunny

=begin
So there are 4 types of timings.
Immediate - Played right after the !play command
Tallied - Played right after the votes are tallied
Idoled - Played right after the idols are played
Super - Played after the votes are read

The way it works is as follows. You have a !play command, which args is the item code. Afterwards
you get a list of targets. Afterwards, that is done.
If you use the !play command again, it cancels out.
The way that is known is if the targets array has (0) or (> 0) items, which decides if no or yes targets.

So, what happens exactly when an item is played?
First, there must be a method so that it cannot be used again. That is simple. Remove the user as an owner.
Though, there's other thing. What if it can be found again? Simple. Make sure the owner is not nil. If 
owner is nil, then the item can be found.

Afterwards, once an item is played, its owner is changed to no one, right after its effects applying.
Which means that when an extra vote is played, it adds 1 to allowed_votes then kills itself.
Except, that effect only happens when the timing is due. Like, immediate -> kills immediately.
tallied -> kills when votes are tallied

So, item has timing and function code. if timing is immediate, call function code and erase item.
otherwise, the count command will call the function in its appropriated times. no, not erase item.
Change its owner to 0.

Also, about clues...
ah yes, the find command. although, a find command kinda...doesn't jive right now.

=end
    def self.playItem(event,targets,item)

        case item.timing
        when 'Now'
            item.functions.each do |function|
                council = Council.find_by(stage: [0,1], season: Setting.last.season)
                case function
                when 'extra_vote'
                    player = Player.find_by(id: item.owner, season: Setting.last.season)
                    vote = Vote.find_by(council: council.id, player: player.id)

                    BOT.channel(council.channel_id).send_embed do |embed|
                        embed.title = "**#{player.name} used #{item.name}!**"
                        embed.description = "They will now be able to cast one additional vote during this tribal council."
                        embed.color = event.server.role(TRIBAL_PING).color
                    end
                    vote.update(allowed: vote.allowed + 1, votes: vote.votes + [vote.votes.last])
                    item.update(targets: [player.id], owner: 0)

                when 'steal_vote'

                when 'block_vote'

                end
            end
        else
            player = Player.find_by(id: item.owner, season: Setting.last.season)
            allowed_targets = 1
            @targets = []
            item.functions.each do |function|
                case function
                when 'swap_idol'
                end
            end

            council = Council.find_by(season: Setting.last.season, stage: [0,1])
            enemies = Vote.where(council: council.id).excluding(Vote.where(player: player.id)).map(&:player).map { |n| Player.find_by(id: n, status: 'In') }
            enemies.delete(nil)

            enemies << player

            text = enemies.map do |en|
                "**#{en.id}** — #{en.name}"
            end

            allowed_targets.times do 
                event.channel.send_embed do |embed|
                    embed.title = "Who would you like to play it on?"
                    embed.description = text.join("\n")
                    embed.color = event.server.role(Tribe.find_by(id: player.tribe).role_id).color
                end

                await = event.user.await!(timeout: 80)

                event.respond("You didn't pick a target...") if await == nil
                break if await == nil


                content = await.message.content.gsub('myself', player.id)

                text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content }
                id_attempt = options.filter { |id| id == content.to_i }
                if text_attempt.size == 1
                    @targets << Player.find_by(name: text_attempt[0], season: Setting.last.season, status: ALIVE)
                elsif id_attempt.size == 1
                    @targets << Player.find_by(id: id_attempt[0])
                else
                    event.respond("There's no single seedling that matches that.") unless content == ''
                end
            end


            unless @targets = []

            else
                event.respond("You're now using **#{item.name}** on #{@targets.map(&:name).join('**, **')}**\nPlay it again if you want to cancel it.")
                item.update(targets: @targets.map(&:id))
            end

        end


    end

end