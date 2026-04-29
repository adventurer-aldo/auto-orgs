require 'securerandom'

class Sunny
  def self.pending_legacy_item_plays
    @pending_legacy_item_plays ||= {}
  end

  def self.legacy_item_play_item_options
    Item.where.not(season_id: Setting.season_id).order(:season_id, :name).first(25).map do |item|
      {
        label: item.name[0, 100],
        value: item.id.to_s,
        description: "S#{item.season_id} | #{Array(item.functions).join(', ')}"[0, 100]
      }
    end
  end

  def self.legacy_item_play_player_options(season_id)
    Player.where(season_id: season_id).order(:name).first(25).map do |player|
      {
        label: player.name[0, 100],
        value: player.id.to_s,
        description: "Player ID #{player.id}"
      }
    end
  end

  def self.legacy_item_play_item_view(token)
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(
        custom_id: "legacy_item_play_item:#{token}",
        options: legacy_item_play_item_options,
        placeholder: 'Choose an old-season item',
        min_values: 1,
        max_values: 1
      )
    end
    view
  end

  def self.legacy_item_play_owner_view(token, season_id)
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(
        custom_id: "legacy_item_play_owner:#{token}",
        options: legacy_item_play_player_options(season_id),
        placeholder: 'Choose who played it',
        min_values: 1,
        max_values: 1
      )
    end
    view
  end

  def self.legacy_item_play_target_view(token, season_id)
    options = [{ label: 'No target', value: 'none', description: 'This play did not target another castaway' }] + legacy_item_play_player_options(season_id)
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(
        custom_id: "legacy_item_play_targets:#{token}",
        options: options.first(25),
        placeholder: 'Choose target(s), or No target',
        min_values: 1,
        max_values: [options.size, 25].min
      )
    end
    view
  end

  BOT.command :test do |event, *args|
    break unless event.user.id.host?

    players = Player.all
    updated = []
    failed = []
    players.each do |player|
      begin
        upload_player_image(player, BOT.user(player.user_id).avatar_url)
        updated << player.name
      rescue StandardError => e
        failed << "#{player.name}: #{e.message}"
      end
    end

    response = ["Attached current Discord avatars for #{updated.size} players."]
    response << "Failed:\n#{failed.join("\n")}" if failed.any?
    event.respond(response.join("\n"))
  end

  BOT.command :cast_image do |event, *args|
    season = args[0] ? Season.find_by(id: args[0].to_i) : Setting.season

    return event.respond('Season not found.') if season.nil?

    event.channel.send_file(Sunny.get_season_cast_image(season), filename: "season-#{season.id}.png")
  end

  BOT.command :get_image do |event, *args|
    query = args.join(' ')
    return event.respond('Give me a player id or name.') if query.empty?

    player = if query.to_i.positive?
               Player.find_by(id: query.to_i)
             else
               matches = Player.where('LOWER(name) LIKE ?', "%#{query.downcase}%")
               matches.size == 1 ? matches.first : nil
             end

    return event.respond("There's no single player that matches that.") unless player
    return event.respond("There's no image attached for this player") unless Shrine.storages[:store].exists?(player.image_storage_id)

    event.channel.send_file(Shrine.storages[:store].open(player.image_storage_id), filename: "player-#{player.id}.png")
  end

  def self.get_season_cast_image(season)
    players = Player.where(season_id: season.id).sort_by { |player| [player.rank.nil? ? 1 : 0, player.rank || 0, player.name] }
    season_title = season.respond_to?(:name) && season.name.to_s != '' ? "#{season.id}: #{season.name}" : season.id
    escape_html = ->(text) { text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;') }

    avatars = players.map do |player|
      avatar_url = player_image_or_avatar_url(player)
      %Q(
        <div class="player">
          <img class="avatar" src="#{avatar_url}">
          <div class="name">#{escape_html.call(player.name)}</div>
        </div>)
    end

    base = %Q(
      <section class="season-cast">
        <h1>Season #{escape_html.call(season_title)}</h1>
        <div class="players">
          #{avatars.join('')}
        </div>
      </section>

      <style>
        body {
          font-family: Arial, Helvetica, sans-serif;
        }

        .season-cast {
          background: #f7f2e8;
          border: 8px solid #262626;
          color: #262626;
          padding: 28px;
          width: 980px;
        }

        h1 {
          font-size: 52px;
          font-weight: 800;
          line-height: 1;
          margin: 0 0 28px;
          text-align: center;
        }

        .players {
          display: grid;
          grid-template-columns: repeat(5, 1fr);
          gap: 24px 18px;
        }

        .player {
          align-items: center;
          display: flex;
          flex-direction: column;
          min-width: 0;
        }

        .avatar {
          border: 5px solid #262626;
          border-radius: 50%;
          height: 140px;
          object-fit: cover;
          width: 140px;
        }

        .name {
          font-size: 22px;
          font-weight: 700;
          margin-top: 10px;
          max-width: 170px;
          overflow-wrap: anywhere;
          text-align: center;
        }
      </style>)

    html_to_image(base)
  end

  def self.get_user_circular_avatar(user_id)
    a = Tempfile.new(['hey', 'png'])
    base = MiniMagick::Image.open(BOT.user(user_id).avatar_url)
    size = [base.width, base.height].min
    circle = Tempfile.new(['circle', '.png'])
    MiniMagick::Tool.new('convert') do |c|
      c.size "#{size}x#{size}"
      c.xc "none"
      c.draw("circle #{size/2},#{size/2} #{size/2},0")
      c.crop "#{size}x#{size}+0+0"
      c << circle.path
    end
    base.composite(circle) do |c|
      c.background "none"
      c.compose "DstIn"
      c.alpha "set"
      c.gravity "center"
    end.write(a.path)
    return a
  end

  BOT.command :test_circle do |event|
    event.channel.send_file(get_user_circular_avatar(event.user.id), filename: "You.png")
  end

  BOT.command :legacy_item_plays do |event|
    break unless event.user.id.host?

    if legacy_item_play_item_options.empty?
      event.respond('No legacy items found outside the latest season.')
      break
    end

    token = SecureRandom.hex(8)
    pending_legacy_item_plays[token] = { user_id: event.user.id }
    event.channel.send_message('Choose the legacy item to sort.', false, nil, nil, nil, nil, legacy_item_play_item_view(token))
  end

  BOT.string_select(custom_id: /\Alegacy_item_play_item:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_legacy_item_plays[token]
    if payload.nil? || payload[:user_id] != event.user.id || !event.user.id.host?
      event.respond(content: 'This legacy item sorting flow is no longer available to you.', ephemeral: true)
      break
    end

    item = Item.find_by(id: event.values.first.to_i)
    unless item && item.season_id != Setting.season_id
      pending_legacy_item_plays.delete(token)
      event.update_message(content: 'That legacy item no longer exists.', components: nil)
      break
    end
    if legacy_item_play_player_options(item.season_id).empty?
      pending_legacy_item_plays.delete(token)
      event.update_message(content: "Season #{item.season_id} has no players to choose from.", components: nil)
      break
    end

    payload[:item_id] = item.id
    event.update_message(content: "Who played **#{item.name}**?", components: legacy_item_play_owner_view(token, item.season_id))
  end

  BOT.string_select(custom_id: /\Alegacy_item_play_owner:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_legacy_item_plays[token]
    if payload.nil? || payload[:user_id] != event.user.id || !event.user.id.host?
      event.respond(content: 'This legacy item sorting flow is no longer available to you.', ephemeral: true)
      break
    end

    item = Item.find_by(id: payload[:item_id])
    owner = Player.find_by(id: event.values.first.to_i, season_id: item&.season_id)
    unless item && owner
      pending_legacy_item_plays.delete(token)
      event.update_message(content: 'That legacy item or owner no longer exists.', components: nil)
      break
    end

    payload[:owner_id] = owner.id
    event.update_message(content: "Who was **#{item.name}** played on?", components: legacy_item_play_target_view(token, item.season_id))
  end

  BOT.string_select(custom_id: /\Alegacy_item_play_targets:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_legacy_item_plays.delete(token)
    if payload.nil? || payload[:user_id] != event.user.id || !event.user.id.host?
      event.respond(content: 'This legacy item sorting flow is no longer available to you.', ephemeral: true)
      break
    end

    item = Item.find_by(id: payload[:item_id])
    owner = Player.find_by(id: payload[:owner_id], season_id: item&.season_id)
    unless item && owner
      event.update_message(content: 'That legacy item or owner no longer exists.', components: nil)
      break
    end

    target_ids = event.values.reject { |value| value == 'none' }.map(&:to_i)
    targets = Player.where(id: target_ids, season_id: item.season_id).to_a
    item.update(player_id: owner.id, targets: targets.map(&:id), played: true)
    record_event("item_played#{targets.empty? ? '' : ":details= on #{targets.map(&:name).join(', ')}"}", player: owner, item: item)
    event.update_message(
      content: "Sorted **#{item.name}** as played by **#{owner.name}**#{targets.empty? ? '' : " on #{targets.map(&:name).join(', ')}"}.",
      components: nil
    )
  end
end
