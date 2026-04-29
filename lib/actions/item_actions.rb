class Sunny
  def self.item_command_player(event, statuses: ALIVE)
    if event.user.id.host?
      Player.find_by(submissions: event.channel.id, season_id: Setting.season_id, status: statuses) ||
        Player.find_by(confessional: event.channel.id, season_id: Setting.season_id, status: statuses)
    else
      Player.find_by(user_id: event.user.id, season_id: Setting.season_id, status: statuses)
    end
  end

  BOT.command :give, description: 'Give an item.' do |event, *args|
    break unless event.user.id.player? || event.user.id.host?

    event.respond("You didn't write a code!") if args[0].nil?
    break if args[0].nil?

    player = item_command_player(event)
    break unless player

    item = Item.where(code: args[0], player_id: player.id, season_id: Setting.season_id)

    break unless [player.confessional, player.submissions].include? event.channel.id

    event.respond("You don't have any item with that code.") unless item.exists?
    break unless item.exists?

    item = item.first

    unless item.targets.empty?
      event.respond("You're already using **#{item.name}**. Giving it away will cancel that play. Are you sure?")
      confirmation = event.user.await!(timeout: 60)
      event.respond('Giving an item failed.') if confirmation.nil?
      break if confirmation.nil?

      unless Setting.confirmation?(confirmation.message.content)
        event.respond('I guess not...')
        break
      end

      cancel_item_play(item)
      record_and_send_event('item_stopped', player: player, item: item)
      event.respond("Cancelled playing **#{item.name}**.")
    end

    enemies = Player.where(season_id: Setting.season_id, status: ALIVE).where.not(id: player.id)
    text = enemies.map do |en|
      "**#{en.id}** — #{en.name}"
    end

    event.channel.send_embed do |embed|
      embed.title = 'Who would you like to give it to?'
      embed.description = text.join("\n")
      embed.color = event.server.role(player.tribe.role_id).color
    end

    msg = event.user.await!(timeout: 60)
    event.respond('Giving an item failed.') unless msg
    break unless msg

    content = msg.message.content
    targets = []

    text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content.downcase }
    id_attempt = enemies.map(&:id).filter { |id| id == content.to_i }
    if text_attempt.size == 1
      targets << Player.find_by(name: text_attempt[0], season_id: Setting.season_id, status: ALIVE)
    elsif id_attempt.size == 1
      targets << Player.find_by(id: id_attempt[0])
    else
      event.respond("There's no single castaway that matches that.") unless content == ''
    end

    if !targets.empty?
      event.respond("Are you sure you want to give your **#{item.name}** to **#{targets.first.name}**?")
      msger = event.user.await!(timeout: 60)
      event.respond('Took too long to confirm. Take your time to think about this one.') unless msger
      break unless msger

      if Setting.confirmation?(msger.message.content.downcase)
        item.update(player_id: targets.first.id)
        record_and_send_event("item_given:target=#{targets.first.name}", player: player, item: item)
        record_and_send_event("item_received:from=#{player.name}", player: targets.first, item: item)
        event.respond("**#{item.name}** now belongs to **#{targets.first.name}**")
        BOT.channel(targets.first.submissions).send_embed do |embed|
          embed.title = "#{player.name} has sent you an item!"
          embed.description = "**#{item.name}**\n#{item.description}\n**Code:** `#{item.code}`"
        end
      else
        event.respond 'I guess not...'
      end
    else
      event.respond('Giving an item failed.')
    end
  end

  BOT.command :play, description: 'Plays an item.' do |event, *args|
    break unless event.user.id.player? || event.user.id.host?

    event.respond("You didn't write a code!") if args[0].nil?
    break if args[0].nil?

    player = item_command_player(event)
    break unless player

    item = player.items.where(code: args[0])

    break unless [player.confessional, player.submissions].include? event.channel.id

    event.respond("You don't have any item with that code.") unless item.exists?
    break unless item.exists?

    item = item.first
    council = if item.early?
                Council.where(stage: [0], season_id: Setting.season_id).exists?
              elsif item.now?
                Council.where(stage: [0, 1], season_id: Setting.season_id).exists?
              elsif item.tallied?
                Council.where(stage: [0, 1, 2], season_id: Setting.season_id).exists?
              else
                false
              end

    event.respond("You're not able to play this item now!") unless council == true
    break unless council == true

    targets = item.targets
    unless targets == []
      cancel_item_play(item)
      record_and_send_event('item_stopped', player: player, item: item)
      event.respond("You've cancelled playing **#{item.name}**.")
    end
    break unless targets == []

    play_item(event, (args - [args[0]]), item)
  end
end
