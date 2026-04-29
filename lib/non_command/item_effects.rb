class Sunny
  def self.item_vote_target(event, player, council, prompt)
    enemies = Vote.where(council_id: council.id).excluding(Vote.where(player_id: player.id)).map(&:player).filter { |n| n&.status == 'In' }
    enemies.delete(nil)

    event.channel.send_embed do |embed|
      embed.title = prompt
      embed.description = enemies.map { |en| "**#{en.id}** — #{en.name}" }.join("\n")
      embed.color = event.server.role(player.tribe.role_id).color
    end

    await = event.user.await!(timeout: 80)
    event.respond("You didn't pick a target...") if await.nil?
    return nil if await.nil?

    content = await.message.content
    text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content.downcase }
    id_attempt = enemies.map(&:id).filter { |id| id == content.to_i }

    if text_attempt.size == 1
      Player.find_by(name: text_attempt[0], season_id: Setting.season_id, status: ALIVE)
    elsif id_attempt.size == 1
      Player.find_by(id: id_attempt[0])
    else
      event.respond("There's no single castaway that matches that.") unless content == ''
      nil
    end
  end

  def self.item_vote_parchment(event, target)
    event.respond('Time to upload a parchment! Right in your next message!')
    file = URI.parse(Setting.parchment_url).open
    BOT.send_file(event.channel, file, filename: 'parchment.png')
    image = event.user.await!(timeout: 600)

    if image && !image.message.attachments.empty?
      parch = image.message.attachments.first.url
      return parch if parch =~ /.*\.[pj][np]g/
    elsif image
      parch = image.message.content[/https:\/\/cdn\.discordapp\.com\/attachments.*\.[pj][np]g/]
      parch ||= image.message.content[/https:\/\/media\.discordapp\.net\/attachments.*\.[pj][np]g/]
      return parch unless parch.nil?
    end

    event.respond "I couldn't find a parchment there... Guess I'll make one for you."
    source_message = event.channel.send_file generate_parchment(target.name)
    source_message.attachments.first&.url || '0'
  end

  def self.add_item_vote(vote, target_id, parchment)
    voted = Array(vote.votes)
    parchments = Array(vote.parchments)
    index = voted.size
    voted << target_id
    parchments << parchment
    vote.update(allowed: vote.allowed + 1, votes: voted, parchments: parchments)
    index
  end

  def self.remove_item_vote_at(vote, index)
    voted = Array(vote.votes)
    parchments = Array(vote.parchments)
    return false if index.nil? || index.negative? || index >= voted.size

    voted.delete_at(index)
    parchments.delete_at(index)
    vote.update(allowed: [vote.allowed - 1, 0].max, votes: voted, parchments: parchments)
    true
  end

  def self.remove_last_item_vote(vote)
    voted = Array(vote.votes)
    parchments = Array(vote.parchments)
    return nil if voted.empty?

    index = voted.size - 1
    voted.delete_at(index)
    parchments.delete_at(index)
    vote.update(allowed: [vote.allowed - 1, 0].max, votes: voted, parchments: parchments)
    index
  end

  def self.cancel_item_play(item)
    council = Council.where(stage: [0, 1], season_id: Setting.season_id).last
    player = item.player
    return item.update(targets: []) unless council && player

    if item.functions.include?('extra_vote')
      vote = Vote.find_by(council_id: council.id, player_id: player.id)
      remove_item_vote_at(vote, item.targets.first.to_i) if vote
    elsif item.functions.include?('steal_vote')
      owner_vote_index = item.targets[1].to_i
      owner_vote = Vote.find_by(council_id: council.id, player_id: player.id)
      remove_item_vote_at(owner_vote, owner_vote_index) if owner_vote
    end

    item.update(targets: [])
  end

  def self.play_item(event, targets, item)
    if item.early?
      item.functions.each do |function| 
        council = Council.where(stage: [0], season_id: Setting.season_id).last
        player = item.player
        case function
        when 'safety_without_power'
          event.respond('Are you sure?')
          confirmation = event.user.await!(timeout: 50)

          event.respond("You didn't confirm. Try again if you want to play it.") if confirmation.nil?
          break if confirmation.nil?

          event.respond('I guess not...') unless Setting.confirmation?(confirmation.message.content)
          break unless Setting.confirmation?(confirmation.message.content)

          vote = Vote.find_by(council_id: council.id, player_id: player.id)

          Vote.where(council_id: council.id).each do |vote| 
            if vote.votes.include? player.id
              new_votes = vote.votes.map_with_index do |prev| 
                if prev == player.id
                  BOT.channel(vote.player.submissions).send_embed do |embed|
                    embed.title = "Your vote has been invalidated!"
                    embed.description = "**#{player.name}** has used the **Safety Without Power** advantage, granting them exit from the Tribal Council you're both attending."
                    embed.color = BOT.server(Setting.server_id).role(player.tribe.role_id).color
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
            embed.color = event.server.role(Setting.tribal_ping_role_id).color
          end

          item.update(targets: [player.id], player_id: 0)

        end
      end
    elsif item.now?
      item.functions.each do |function|
        council = Council.where(stage: [0, 1], season_id: Setting.season_id).last
        player = item.player
        case function
        when 'extra_vote'
          target = item_vote_target(event, player, council, "Who would you like to cast your extra vote against?")
          event.respond('Playing this item failed!') if target.nil?
          break if target.nil?

          parchment = item_vote_parchment(event, target)
          vote = Vote.find_by(council_id: council.id, player_id: player.id)
          vote_index = add_item_vote(vote, target.id, parchment)

          BOT.channel(council.channel_id).send_embed do |embed|
            embed.title = "#{player.name} used #{item.name}!"
            embed.description = 'They have cast one additional vote during this tribal council.'
            embed.color = event.server.role(Setting.tribal_ping_role_id).color
          end
          item.update(targets: [vote_index])
          event.respond("You successfuly played #{item.name}.")

        when 'steal_vote'
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
          stolen_target = nil
          if text_attempt.size == 1
            stolen_target = Player.find_by(name: text_attempt[0], season_id: Setting.season_id, status: ALIVE)
          elsif id_attempt.size == 1
            stolen_target = Player.find_by(id: id_attempt[0])
          elsif content != ''
            event.respond("There's no single castaway that matches that.")
          end

          event.respond('Playing this item failed!') if stolen_target.nil?
          break if stolen_target.nil?

          vote_target = item_vote_target(event, player, council, "Who would you like to cast the stolen vote against?")
          event.respond('Playing this item failed!') if vote_target.nil?
          break if vote_target.nil?

          parchment = item_vote_parchment(event, vote_target)
          owner_vote = Vote.find_by(council_id: council.id, player_id: player.id)
          vote_index = add_item_vote(owner_vote, vote_target.id, parchment)

          event.respond("You used **#{item.name}** on **#{stolen_target.name}**")

          BOT.channel(council.channel_id).send_embed do |embed|
            embed.title = "#{player.name} used #{item.name} on #{stolen_target.name}!"
            embed.description = "This advantage steals one of #{stolen_target.name}'s votes and allows #{player.name} to cast an extra vote with the stolen parchment..."
            embed.color = event.server.role(Setting.tribal_ping_role_id).color
          end

          item.update(targets: [stolen_target.id, vote_index])
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
            targets << Player.find_by(name: text_attempt[0], season_id: Setting.season_id, status: ALIVE)
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

          event.respond('I guess not...') unless Setting.confirmation?(confirmation.message.content)
          break unless Setting.confirmation?(confirmation.message.content)

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
            embed.color = event.server.role(Setting.tribal_ping_role_id).color
          end

          item.update(player_id: nil, targets: targets.map(&:id))
        end
      end
    else
      player = Player.find_by(id: item.player_id, season_id: Setting.season_id)
      allowed_targets = 1
      targets = []
      item.functions.each do |function|
        case function
        when 'idol'
          council = Council.where(season_id: Setting.season_id, stage: [0, 1, 2]).last
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
              targets << Player.find_by(name: text_attempt[0], season_id: Setting.season_id, status: ALIVE)
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
