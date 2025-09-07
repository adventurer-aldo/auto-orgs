class Sunny
  def self.playItem(event, targets, item)
    case item.timing
    when 'Early'
      council = Council.where(stage: [0], season_id: Setting.last.season).last
      player = item.player
      case function
      when 'safety_without_power'
        event.respond('Are you sure?')
        confirmation = event.user.await!(timeout: 50)

        event.respond("You didn't confirm. Try again if you want to play it.") if confirmation.nil?
        break if confirmation.nil?

        event.respond('I guess not...') unless confirmation.message.content.downcase.include? CONFIRMATIONS
        break unless confirmation.message.content.downcase.include? CONFIRMATIONS

        vote = Vote.find_by(council_id: council.id, player_id: player.id)

        Vote.where(council_id: council.id).each do |vote| 
          if vote.votes.include? player.id
            new_votes = vote.votes.map_with_index do |prev| 
              if prev == player.id
                BOT.channel(vote.player.submissions).send_embed do |embed|
                  embed.title = "Your vote has been invalidated!"
                  embed.description = "**#{player.name}** has used the **Safety Without Power** advantage, granting them exit from the Tribal Council you're both attending."
                  embed.color = BOT.server(ALVIVOR_ID).role(player.tribe.role_id).color
                  embed.footer = "A different vote must be cast right away."
                end
                0
              else 
                prev 
              end
            end

          end
        end
        vote.destroy
        event.respond("You successfuly played #{item.name}.")

        BOT.channel(council.channel_id).send_embed do |embed|
          embed.title = "#{player.name} used #{item.name}!"
          embed.description = 'They have left the Tribal Council area... And as such, they cannot vote, be voted for, spectate nor play any Items.'
          embed.color = event.server.role(TRIBAL_PING).color
        end

        item.update(targets: [player.id], player_id: 0)

      end
    when 'Now'
      item.functions.each do |function|
        council = Council.where(stage: [0, 1], season_id: Setting.last.season).last
        player = item.player
        case function
        when 'pet_food'
          event.respond('Are you sure?')
          confirmation = event.user.await!(timeout: 50)

          event.respond("You didn't confirm. Try again if you want to play it.") if confirmation.nil?
          break if confirmation.nil?

          event.respond('I guess not...') unless confirmation.message.content.downcase.include? CONFIRMATIONS
          break unless confirmation.message.content.downcase.include? CONFIRMATIONS

          vote = Vote.find_by(council_id: council.id, player_id: player.id)

          vote.update(allowed: vote.allowed + 1, votes: vote.votes + [vote.votes.last], parchments: vote.parchments + [vote.parchments.last])
          item.update(targets: [player.id], player_id: nil)
          event.respond("You successfuly played #{item.name}.")
        when 'extra_vote'
          event.respond('Are you sure? Everyone will be informed of your advantage being used.')
          confirmation = event.user.await!(timeout: 50)

          event.respond("You didn't confirm. Try again if you want to play it.") if confirmation.nil?
          break if confirmation.nil?

          event.respond('I guess not...') unless confirmation.message.content.downcase.include? CONFIRMATIONS
          break unless confirmation.message.content.downcase.include? CONFIRMATIONS

          vote = Vote.find_by(council_id: council.id, player_id: player.id)

          BOT.channel(council.channel_id).send_embed do |embed|
            embed.title = "#{player.name} used #{item.name}!"
            embed.description = 'They will now be able to cast one additional vote during this tribal council.'
            embed.color = event.server.role(TRIBAL_PING).color
          end
          vote.update(allowed: vote.allowed + 1, votes: vote.votes + [vote.votes.last], parchments: vote.parchments + [vote.parchments.last])
          item.update(targets: [player.id], player_id: nil)
          event.respond("You successfuly played #{item.name}.")

        when 'steal_vote'
          targets = []
          enemies = Vote.where(council_id: council.id, allowed: Array(1..10)).excluding(Vote.where(player_id: player.id)).map(&:player)
          enemies.delete(nil)

          text = enemies.map do |en|
            "**#{en.id}** — #{en.name}"
          end

          event.channel.send_embed do |embed|
            embed.title = "Who would you like to play #{item.name} on?"
            embed.description = text.join("\n")
            embed.color = event.server.role(player.tribe.role_id).color
          end

          await = event.user.await!(timeout: 80)

          event.respond("You didn't pick a target...") if await.nil?
          break if await.nil?

          content = await.message.content

          text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content.downcase }
          id_attempt = enemies.map(&:id).filter { |id| id == content.to_i }
          if text_attempt.size == 1
            targets << Player.find_by(name: text_attempt[0], season_id: Setting.last.season, status: ALIVE)
          elsif id_attempt.size == 1
            targets << Player.find_by(id: id_attempt[0])
          elsif content != ''
            event.respond("There's no single castaway that matches that.")
          end

          event.respond('Playing this item failed!') if targets.empty?
          break if targets.empty?

          event.respond("You're about to use **#{item.name}** on **#{targets.map(&:name).join(', ')}**. Are you sure? Everyone will be informed of your advantage being used.")
          confirmation = event.user.await!(timeout: 50)

          event.respond("You didn't confirm in time. Try again if you want to play it.") if confirmation.nil?
          break if confirmation.nil?

          event.respond('I guess not...') unless confirmation.message.content.downcase.include? CONFIRMATIONS
          break unless confirmation.message.content.downcase.include? CONFIRMATIONS

          event.respond("You used **#{item.name}** on **#{targets.map(&:name).join('**, **').gsub(player.name,'yourself')}**")
          Vote.where(council_id: council.id, player_id: targets.map(&:id)).each do |vote_block|
            a = vote_block.votes
            a.delete_at(-1)
            b = vote_block.parchments
            b.delete_at(-1)
            new_allowed = vote_block.allowed - 1
            new_allowed = 0 if new_allowed.negative?
            vote_block.update(allowed: new_allowed, votes: a, parchments: b)
          end

          Vote.where(council_id: council.id, player_id: player.id).each do |vote_add|
            vote_add.update(allowed: vote_add.allowed + 1, votes: vote_add.votes + [vote_add.votes.last], parchments: vote_add.parchments + [vote_add.parchments.last] )
          end

          BOT.channel(council.channel_id).send_embed do |embed|
            embed.title = "#{player.name} used #{item.name} on #{targets.map(&:name).join(', ')}!"
            embed.description = "This advantage steals one of #{targets.map(&:name).join(', ')}'s votes and allows #{player.name} to cast an extra vote with the stolen parchment..."
            embed.color = event.server.role(TRIBAL_PING).color
          end

          item.update(player_id: 0, targets: targets.map(&:id))
        when 'block_vote'
          targets = []
          enemies = Vote.where(council_id: council.id, allowed: Array(1..10)).excluding(Vote.where(player_id: player.id)).map(&:player).map { |n| Player.find_by(id: n) }
          enemies.delete(nil)

          text = enemies.map do |en|
            "**#{en.id}** — #{en.name}"
          end

          event.channel.send_embed do |embed|
            embed.title = "Who would you like to play #{item.name} on?"
            embed.description = text.join("\n")
            embed.color = event.server.role(player.tribe.role_id).color
          end

          await = event.user.await!(timeout: 80)

          event.respond("You didn't pick a target in time...") if await.nil?
          break if await.nil?

          content = await.message.content

          text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content.downcase }
          id_attempt = enemies.map(&:id).filter { |id| id == content.to_i }
          if text_attempt.size == 1
            targets << Player.find_by(name: text_attempt[0], season_id: Setting.last.season, status: ALIVE)
          elsif id_attempt.size == 1
            targets << Player.find_by(id: id_attempt[0])
          elsif content != ''
            event.respond("There's no single castaway that matches that.")
          end

          event.respond('Playing this item failed!') if targets.empty?
          break if targets.empty?

          event.respond("You're about to use **#{item.name}** on **#{targets.map(&:name).join(', ')}**. Are you sure?")
          confirmation = event.user.await!(timeout: 50)

          event.respond("You didn't confirm in time. Try again if you want to play it.") if confirmation.nil?
          break if confirmation.nil?

          event.respond('I guess not...') unless confirmation.message.content.downcase.include? CONFIRMATIONS
          break unless confirmation.message.content.downcase.include? CONFIRMATIONS

          event.respond("You used **#{item.name}** on **#{targets.map(&:name).join('**, **').gsub(player.name, 'yourself')}**")
          Vote.where(council_id: council.id, player_id: targets.map(&:id)).each do |vote_block|
            a = vote_block.votes
            a.delete_at(a.size - 1)
            b = vote_block.parchments
            b.delete_at(b.size - 1)
            new_allowed = vote_block.allowed - 1
            new_allowed = 0 if new_allowed.negative?
            vote_block.update(allowed: new_allowed, votes: a, parchments: b)
          end

          BOT.channel(council.channel_id).send_embed do |embed|
            embed.title = "#{player.name} used #{item.name} on #{targets.map(&:name).join(', ')}!"
            embed.description = "This advantage blocks one of #{targets.map(&:name).join(', ')}'s votes."
            embed.color = event.server.role(TRIBAL_PING).color
          end

          item.update(player_id: nil, targets: targets.map(&:id))
        end
      end
    else
      player = Player.find_by(id: item.player_id, season_id: Setting.last.season)
      allowed_targets = 1
      targets = []
      item.functions.each do |function|
        case function
        when 'idol'
          council = Council.where(season_id: Setting.last.season, stage: [0, 1, 2]).last
          enemies = Vote.where(council_id: council.id).map(&:player).map { |n| Player.find_by(id: n, status: 'In') }
          enemies.delete(nil)

          text = enemies.map do |en|
            "**#{en.id}** — #{en.name}"
          end

          allowed_targets.times do 
            event.channel.send_embed do |embed|
              embed.title = "Who would you like to play #{item.name} on?"
              embed.description = text.join("\n")
              embed.color = event.server.role(player.tribe.role_id).color
            end

            await = event.user.await!(timeout: 80)

            event.respond("You didn't pick a target...") if await.nil?
            break if await.nil?


            content = await.message.content.gsub('myself', player.id.to_s)

            text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content.downcase }
            id_attempt = enemies.map(&:id).filter { |id| id == content.to_i }
            if text_attempt.size == 1
              targets << Player.find_by(name: text_attempt[0], season_id: Setting.last.season, status: ALIVE)
            elsif id_attempt.size == 1
              targets << Player.find_by(id: id_attempt[0])
            elsif content != ''
              event.respond("There's no single castaway that matches that.")
            end
          end

          if targets == []
            event.respond('Playing this item failed!')
          else
            event.respond("You're now using **#{item.name}** on **#{targets.map(&:name).join('**, **').gsub(player.name,'yourself')}**\nPlay it again if you want to cancel it.")
            item.update(targets: targets.map(&:id))
          end

        end
      end
    end
    return

  end
end
