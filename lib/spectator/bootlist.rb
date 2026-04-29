class Sunny
  def self.bootlist_channel
    channel_from_setting(:spectator_bootlist_channel_id)
  end

  def self.bootlist_options(players)
    players.first(25).map { |player| { label: player.name[0, 100], value: player.id.to_s } }
  end

  def self.prepare_bootlist_game(event)
    unless bootlist_open?
      event.respond('Bootlist can only open before the first Tribal Council of the season.')
      return
    end

    channel = bootlist_channel
    unless channel
      event.respond(spectator_channel_missing_message('Bootlist Game', :spectator_bootlist_channel_id))
      return
    end

    Setting.spectator_bootlist_is_ongoing = 1
    players = Player.where(season_id: Setting.season_id, status: ALIVE).order(:id).to_a

    channel.send_embed do |embed|
      embed.title = "#{season_title} — Bootlist Game"
      embed.description = "Predict the season boot order once. Put your list in order from first eliminated to winner."
      embed.color = '#CB00FF'
    end

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(
        custom_id: 'BootlistPick',
        options: bootlist_options(players),
        placeholder: 'Choose the boot order',
        min_values: players.size.clamp(1, 25),
        max_values: players.size.clamp(1, 25)
      )
    end
    channel.send_message('Choose everyone in your predicted order.', false, nil, nil, nil, nil, view)
    channel.send_message('Discord selects can only hold 25 names, so hosts should collect larger casts manually for now.') if players.size > 25
  end

  BOT.command :prepare_bootlist do |event|
    break unless event.user.id.host?

    prepare_bootlist_game(event)
  end

  BOT.string_select(custom_id: 'BootlistPick') do |event|
    event.defer_update

    unless Setting.spectator_bootlist_is_ongoing == 1 && bootlist_open?
      event.send_message(content: 'Bootlist picks are closed.', ephemeral: true)
      break
    end

    existing = SpectatorGame::Bootlist.find_by(user_id: event.user.id, season_id: Setting.season_id)
    if existing
      event.send_message(content: 'You already submitted a bootlist.', ephemeral: true)
      break
    end

    values = event.values.map(&:to_i)
    if values.uniq.size != values.size
      event.send_message(content: 'Each castaway can only appear once.', ephemeral: true)
      break
    end

    bootlist = SpectatorGame::Bootlist.create(user_id: event.user.id, season_id: Setting.season_id)
    unless set_model_value(bootlist, %w[rankings picks bootlist player_ids players], values)
      event.send_message(content: 'Bootlist table needs an array column named rankings, picks, bootlist, player_ids, or players.', ephemeral: true)
      break
    end

    event.send_message(content: 'Your bootlist has been submitted.', ephemeral: true)
  end
end
