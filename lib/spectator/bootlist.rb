require 'securerandom'

class Sunny
  def self.pending_bootlists
    @pending_bootlists ||= {}
  end

  def self.bootlist_channel
    channel_from_setting(:spectator_bootlist_channel_id)
  end

  def self.bootlist_options(players)
    players.first(25).map { |player| { label: player.name[0, 100], value: player.id.to_s } }
  end

  def self.bootlist_values(record)
    record.respond_to?(:values) ? record.values : []
  end

  def self.bootlist_player_lines(values)
    values.each_with_index.map do |player_id, index|
      player = Player.find_by(id: player_id, season_id: Setting.season_id)
      "#{index + 1}. #{player&.name || "Missing player #{player_id}"}"
    end
  end

  def self.bootlist_summary(values)
    "**Your Bootlist**\n#{bootlist_player_lines(values).join("\n")}"
  end

  def self.bootlist_confirmation_view(token)
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.button(custom_id: "bootlist_submit:#{token}", label: 'Submit', style: :success)
      row.button(custom_id: "bootlist_cancel:#{token}", label: 'Cancel', style: :secondary)
    end
    view
  end

  def self.bootlist_check_view
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.button(custom_id: 'bootlist_check', label: 'Check My Bootlist', style: :secondary)
    end
    view
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
    channel.send_message('Already submitted?', false, nil, nil, nil, nil, bootlist_check_view)
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

    token = SecureRandom.hex(8)
    pending_bootlists[token] = { user_id: event.user.id, values: values }

    event.send_message(content: bootlist_summary(values), ephemeral: true, components: bootlist_confirmation_view(token))
  end

  BOT.button(custom_id: /\Abootlist_submit:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_bootlists[token]

    if payload.nil? || payload[:user_id] != event.user.id
      event.respond(content: 'This bootlist draft is no longer available.', ephemeral: true)
      break
    end

    if SpectatorGame::Bootlist.exists?(user_id: event.user.id, season_id: Setting.season_id)
      pending_bootlists.delete(token)
      event.update_message(content: 'You already submitted a bootlist.', components: nil)
      break
    end

    bootlist = SpectatorGame::Bootlist.create(user_id: event.user.id, season_id: Setting.season_id)
    unless set_model_value(bootlist, %w[rankings picks bootlist player_ids players], payload[:values])
      pending_bootlists.delete(token)
      event.update_message(content: 'Bootlist table needs an array column named rankings, picks, bootlist, player_ids, or players.', components: nil)
      break
    end

    pending_bootlists.delete(token)
    event.update_message(content: "#{bootlist_summary(payload[:values])}\n\n**Submitted.**", components: nil)
  end

  BOT.button(custom_id: /\Abootlist_cancel:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_bootlists[token]

    if payload.nil? || payload[:user_id] != event.user.id
      event.respond(content: 'This bootlist draft is no longer available.', ephemeral: true)
      break
    end

    pending_bootlists.delete(token)
    event.update_message(content: 'Bootlist submission cancelled.', components: nil)
  end

  BOT.button(custom_id: 'bootlist_check') do |event|
    bootlist = SpectatorGame::Bootlist.find_by(user_id: event.user.id, season_id: Setting.season_id)

    unless bootlist
      event.respond(content: 'You have not submitted a bootlist yet.', ephemeral: true)
      break
    end

    event.respond(content: bootlist_summary(bootlist_values(bootlist)), ephemeral: true)
  end
end
