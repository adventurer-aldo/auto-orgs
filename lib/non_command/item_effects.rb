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
                player = Player.find_by(id: item.owner, season: Setting.last.season)
                case function
                when 'extra_vote'
                    event.respond("Are you sure?")
                    confirmation = event.user.await!(timeout: 50)

                    event.respond("You didn't confirm. Try again if you want to play it.") if confirmation.nil?
                    break if confirmation.nil?

                    event.respond("Okay!") unless CONFIRMATIONS.include? confirmation.message.content.downcase
                    break unless CONFIRMATIONS.include? confirmation.message.content.downcase

                    vote = Vote.find_by(council: council.id, player: player.id)

                    BOT.channel(council.channel_id).send_embed do |embed|
                        embed.title = "**#{player.name} used #{item.name}!**"
                        embed.description = "They will now be able to cast one additional vote during this tribal council."
                        embed.color = event.server.role(TRIBAL_PING).color
                    end
                    vote.update(allowed: vote.allowed + 1, votes: vote.votes + [vote.votes.last])
                    item.update(targets: [player.id], owner: 0)

                when 'steal_vote'
                    targets = []
                    enemies = Vote.where(council: council.id, allowed: Array(1..10)).excluding(Vote.where(player: player.id)).map(&:player).map { |n| Player.find_by(id: n) }
                    enemies.delete(nil)
        
                    text = enemies.map do |en|
                        "**#{en.id}** — #{en.name}"
                    end

                    event.channel.send_embed do |embed|
                        embed.title = "Who would you like to play it on?"
                        embed.description = text.join("\n")
                        embed.color = event.server.role(Tribe.find_by(id: player.tribe).role_id).color
                    end
    
                    await = event.user.await!(timeout: 80)
    
                    event.respond("You didn't pick a target...") if await == nil
                    break if await == nil

                    content = await.message.content
    
                    text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content }
                    id_attempt = enemies.map(&:id).filter { |id| id == content.to_i }
                    if text_attempt.size == 1
                        targets << Player.find_by(name: text_attempt[0], season: Setting.last.season, status: ALIVE)
                    elsif id_attempt.size == 1
                        targets << Player.find_by(id: id_attempt[0])
                    else
                        event.respond("There's no single seedling that matches that.") unless content == ''
                    end
                    
                    unless targets == []
                        event.respond("You're about to use **#{item.name}** on **#{targets.map(&:name).join(', ')}**. Are you sure?")
                        confirmation = event.user.await!(timeout: 50)
    
                        event.respond("You didn't confirm. Try again if you want to play it.") if confirmation.nil?
                        break if confirmation.nil?
    
                        event.respond("Okay!") unless CONFIRMATIONS.include? confirmation.message.content.downcase
                        break unless CONFIRMATIONS.include? confirmation.message.content.downcase

                        event.respond("You used **#{item.name}** on **#{targets.map(&:name).join('**, **').gsub(player.name,'yourself')}**")
                        Vote.where(council: council, player: targets.map(&:id)).each do |vote|
                            vote.update(allowed: vote.allowed - 1, votes: vote.votes.delete_at(vote.votes.size - 1))
                        end

                        VOTE.where(council: council, player: player.id).each do |vote|
                            vote.update(allowed: vote.allowed + 1, votes: vote.votes + [0])
                        end

                        BOT.channel(council.channel_id).send_embed do |embed|
                            embed.title = "**#{player.name} used #{item.name} on #{targets.map(&:name).join(', ')}!**"
                            embed.description = "This advantage steals one of the target's votes and allows the owner of this advantage to cast an extra vote with the stolen parchment.."
                            embed.color = event.server.role(TRIBAL_PING).color
                        end

                        item.update(owner: 0, targets: targets.map(&:id))
                    else
                        event.respond("Playing this item failed!")
                    end

                when 'block_vote'
                    targets = []
                    enemies = Vote.where(council: council.id, allowed: Array(1..10)).excluding(Vote.where(player: player.id)).map(&:player).map { |n| Player.find_by(id: n) }
                    enemies.delete(nil)
        
                    text = enemies.map do |en|
                        "**#{en.id}** — #{en.name}"
                    end

                    event.channel.send_embed do |embed|
                        embed.title = "Who would you like to play it on?"
                        embed.description = text.join("\n")
                        embed.color = event.server.role(Tribe.find_by(id: player.tribe).role_id).color
                    end
    
                    await = event.user.await!(timeout: 80)
    
                    event.respond("You didn't pick a target...") if await == nil
                    break if await == nil

                    content = await.message.content
    
                    text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content }
                    id_attempt = enemies.map(&:id).filter { |id| id == content.to_i }
                    if text_attempt.size == 1
                        targets << Player.find_by(name: text_attempt[0], season: Setting.last.season, status: ALIVE)
                    elsif id_attempt.size == 1
                        targets << Player.find_by(id: id_attempt[0])
                    else
                        event.respond("There's no single seedling that matches that.") unless content == ''
                    end
                    
                    unless targets == []
                        event.respond("You're about to use **#{item.name}** on **#{targets.map(&:name).join(', ')}**. Are you sure?")
                        confirmation = event.user.await!(timeout: 50)
    
                        event.respond("You didn't confirm. Try again if you want to play it.") if confirmation.nil?
                        break if confirmation.nil?
    
                        event.respond("Okay!") unless CONFIRMATIONS.include? confirmation.message.content.downcase
                        break unless CONFIRMATIONS.include? confirmation.message.content.downcase

                        event.respond("You used **#{item.name}** on **#{targets.map(&:name).join('**, **').gsub(player.name,'yourself')}**")
                        Vote.where(council: council, player: targets.map(&:id)).each do |vote|
                            vote.update(allowed: vote.allowed - 1, votes: vote.votes.delete_at(vote.votes.size - 1))
                        end

                        BOT.channel(council.channel_id).send_embed do |embed|
                            embed.title = "**#{player.name} used #{item.name} on #{targets.map(&:name).join(', ')}!**"
                            embed.description = "This advantage blocks one of the target's votes."
                            embed.color = event.server.role(TRIBAL_PING).color
                        end

                        item.update(owner: 0, targets: targets.map(&:id))
                    else
                        event.respond("Playing this item failed!")
                    end

                end
            end
        else
            player = Player.find_by(id: item.owner, season: Setting.last.season)
            allowed_targets = 1
            targets = []
            item.functions.each do |function|
                case function
                when 'idol'
                    council = Council.where(season: Setting.last.season, stage: [0,1,2]).last
                    enemies = Vote.where(council: council.id).map(&:player).map { |n| Player.find_by(id: n, status: 'In') }
                    enemies.delete(nil)
        
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
        
        
                        content = await.message.content.gsub('myself', player.id.to_s)
        
                        text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content }
                        id_attempt = enemies.map(&:id).filter { |id| id == content.to_i }
                        if text_attempt.size == 1
                            targets << Player.find_by(name: text_attempt[0], season: Setting.last.season, status: ALIVE)
                        elsif id_attempt.size == 1
                            targets << Player.find_by(id: id_attempt[0])
                        else
                            event.respond("There's no single seedling that matches that.") unless content == ''
                        end
                    end
        
        
                    unless targets == []
                        event.respond("You're now using **#{item.name}** on **#{targets.map(&:name).join('**, **').gsub(player.name,'yourself')}**\nPlay it again if you want to cancel it.")
                        item.update(targets: targets.map(&:id))
                    else
                        event.respond("Playing this item failed!")
                    end
                    
                when 'idol_nullifier'
                when 'swap_idol'
                end
            end


        end

        return
    end

end