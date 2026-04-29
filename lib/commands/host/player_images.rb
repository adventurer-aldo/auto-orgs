class Sunny
  def self.pending_player_images
    @pending_player_images ||= {}
  end

  def self.upload_player_image(player, source_url)
    image = MiniMagick::Image.open(source_url)
    image.format('png')

    file = Tempfile.new(["player-#{player.id}-image", '.png'])
    image.write(file.path)

    File.open(file.path, 'rb') do |io|
      Shrine.storages[:store].upload(io, player.image_storage_id)
    end

    player.image_url
  ensure
    file&.close
    file&.unlink
  end

  def self.player_image_or_avatar_url(player)
    return player.image_url if Shrine.storages[:store].exists?(player.image_storage_id)

    BOT.user(player.user_id).avatar_url
  rescue StandardError
    BOT.user(player.user_id).avatar_url
  end

  def self.add_image_options(players)
    players.first(25).map do |player|
      {
        label: player.name[0, 100],
        value: player.id.to_s,
        description: "Player ID #{player.id}"
      }
    end
  end

  def self.add_image_select_view(user_id, players)
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(
        custom_id: "add_image_select:#{user_id}",
        options: add_image_options(players),
        placeholder: 'Choose a castaway',
        min_values: 1,
        max_values: 1
      )
    end
    view
  end

  BOT.command :add_image, description: 'Attaches the uploaded image to a player.' do |event, *args|
    break unless event.user.id.host?

    attachment = event.message.attachments.first
    unless attachment
      event.respond("You didn't upload an image!")
      break
    end

    if args.first
      player = Player.find_by(id: args.first.to_i)
      unless player
        event.respond("Player ID #{args.first} not found.")
        break
      end

      upload_player_image(player, attachment.url)
      event.respond("Attached that image to **#{player.name}**.")
      break
    end

    players = Player.where(season_id: Setting.season_id).order(:name)
    if players.empty?
      event.respond('There are no players in the current season.')
      break
    end

    pending_player_images[event.user.id] = attachment.url
    event.channel.send_message('Choose the player for this image.', false, nil, nil, nil, nil, add_image_select_view(event.user.id, players))
  end

  BOT.string_select(custom_id: /\Aadd_image_select:/) do |event|
    user_id = event.custom_id.split(':', 2).last.to_i
    if user_id != event.user.id || !event.user.id.host?
      event.respond(content: 'Only the host who opened this menu can use it.', ephemeral: true)
      break
    end

    source_url = pending_player_images.delete(event.user.id)
    unless source_url
      event.update_message(content: 'That pending image is gone. Run `!add_image` again with the image attached.', components: nil)
      break
    end

    player = Player.find_by(id: event.values.first.to_i, season_id: Setting.season_id)
    unless player
      event.update_message(content: 'That player is no longer in the current season.', components: nil)
      break
    end

    upload_player_image(player, source_url)
    event.update_message(content: "Attached that image to **#{player.name}**.", components: nil)
  end
end
