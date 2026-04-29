class Sunny
  def self.elimination_options(players)
    players.first(25).map do |player|
      {
        label: player.name[0, 100],
        value: player.id.to_s,
        description: "Player ID #{player.id}"
      }
    end
  end

  def self.elimination_select_view(user_id, players)
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(
        custom_id: "eliminate_select:#{user_id}",
        options: elimination_options(players),
        placeholder: 'Choose a castaway to eliminate',
        min_values: 1,
        max_values: 1
      )
    end
    view
  end

  BOT.command :eliminate, description: 'Removes a castaway from the game.' do |event, *args|
    break unless event.user.id.host?

    content = args.join(' ')
    enemies = Player.where(season_id: Setting.season_id, status: ALIVE).order(:name)
    if content.empty?
      event.respond('There are no available castaways to eliminate.') if enemies.empty?
      break if enemies.empty?

      event.channel.send_message('Choose a castaway to eliminate.', false, nil, nil, nil, nil, elimination_select_view(event.user.id, enemies))
      break
    end

    text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content.downcase }
    id_attempt = enemies.map(&:id).filter { |id| id == content.to_i }
    target = nil
    if text_attempt.size == 1
      target = Player.find_by(name: text_attempt[0], season_id: Setting.season_id)
    elsif id_attempt.size == 1
      target = Player.find_by(id: id_attempt[0], season_id: Setting.season_id)
    else
      event.respond("There's no single castaway that matches that.") unless content == ''
    end

    if target
      loser = target
      eliminate(loser)
      event.respond("#{loser.name} has been eliminated.")
    end
    return
  end

  BOT.string_select(custom_id: /\Aeliminate_select:/) do |event|
    user_id = event.custom_id.split(':', 2).last.to_i
    if user_id != event.user.id || !event.user.id.host?
      event.respond(content: 'Only the host who opened this menu can use it.', ephemeral: true)
      break
    end

    loser = Player.find_by(id: event.values.first.to_i, season_id: Setting.season_id, status: ALIVE)
    unless loser
      event.update_message(content: 'That castaway is no longer available.', components: nil)
      break
    end

    eliminate(loser)
    event.update_message(content: "#{loser.name} has been eliminated.", components: nil)
  end

  BOT.command :rocks, description: 'Quick and simple goes to rocks.' do |event, *args|
    break unless event.user.id.host?

    council = Council.find_by(channel_id: event.channel.id)
    break if council.nil? || council.stage >= 5

    event.message.delete
    event.channel.start_typing
    sleep(3)
    event.respond("We'll be drawing **ROCKS**")
    event.channel.start_typing
    sleep(3)
    event.respond('The castaway that draws the purple rock will be out of the game immediately.')
    event.channel.start_typing
    sleep(3)
    stat =  if args.join(' ').downcase == 'in'
              'In'
            else
              'Idoled'
            end

    seeds = Vote.where(council_id: council.id).map(&:player).map { |n| Player.find_by(id: n, status: stat, season_id: Setting.season_id) }
    seeds.delete(nil)

    event.respond("This will be between #{seeds.map(&:name).join(', ')}")
    event.channel.start_typing
    sleep(3)
    event.respond("Let's get to it!")
    seeds.delete(nil)
    rocks = seeds.map { 0 }
    rocks[0] = 1
    rocks.shuffle!
    seeds.each do |seed|
      event.channel.start_typing
      sleep(3)
      event.respond("#{seed.name} draws a rock...")
      event.channel.start_typing
      sleep(3)
      event.respond('...')
      event.channel.start_typing
      sleep(3)
      if rocks[seeds.index(seed)].zero?
        event.respond("It's a white rock! #{seed.name} is safe.")
        event.channel.start_typing
        sleep(3)
        event.respond '.'
      else
        event.respond('...')
        event.channel.start_typing
        sleep(3)
        event.respond('...')
        event.channel.start_typing
        sleep(3)
        event.respond("It's a **purple rock**...")
        event.channel.start_typing
        sleep(3)
        eliminate(seed)
        event.respond("#{seed.name} has unfortunately been eliminated from the game.")
        council.update(stage: 5)
      end
      break unless rocks[seeds.index(seed)].zero?
    end
    return

  end
end
