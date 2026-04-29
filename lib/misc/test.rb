class Sunny
  def self.legacy_prompt(event, text)
    event.respond(text)
    event.user.await!.message.content.strip
  end

  def self.legacy_yes?(text)
    Setting.confirmation?(text)
  end

  def self.legacy_blank?(text)
    text.to_s.strip.empty? || text.to_s.strip == '-'
  end

  def self.legacy_snowflake(text)
    text.to_s.scan(/\d+/).first&.to_i || 0
  end

  def self.legacy_member(event, text)
    user_id = legacy_snowflake(text)
    return event.server.member(user_id) if user_id.positive?

    query = text.downcase
    event.server.members.find do |member|
      [member.display_name, member.username, member.name].compact.any? { |name| name.downcase.include?(query) }
    end
  end

  def self.legacy_player(season_id, text)
    id = legacy_snowflake(text)
    return Player.find_by(id: id, season_id: season_id) if id.positive?

    query = text.downcase
    matches = Player.where(season_id: season_id).select { |player| player.name.downcase.include?(query) }
    exact = matches.select { |player| player.name.downcase == query }
    matches = exact unless exact.empty?
    matches.size == 1 ? matches.first : nil
  end

  def self.legacy_item_type(text)
    normalized = text.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/\A_+|_+\z/, '')
    return normalized if DEFINED_FUNCTIONS.include?(normalized)

    nil
  end

  def self.legacy_played_attributes(item)
    item.has_attribute?('played') ? { played: true } : {}
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

  BOT.command :eliminator do |event|
    event.channel.send_file(Sunny.get_eliminator_image, filename: 'eliminator.png')
  end

  def self.get_eliminator_image
        base = %Q(
      <table class="table table-primary">
      <thead class="table-dark">
        <tr>
          <th scope="col">Spectator</th>
          <th scope="col">Episode 1</th>
        </tr>
      </thead>
      <tbody>
      #{SpectatorGame::Elimination.where(season_id: Setting.season_id).map do |elim|
          player = Player.find_by(id: elim.player_id)
          %Q(
            <tr>
              <th scope="row">#{BOT.user(elim.user_id).on(Setting.server_id).display_name}</th>
              <td>#{player&.name}</td>
            </tr>)
        end.join('')}
      </tbody>
    </table>)
        html_to_image(base)
  end

  BOT.command :test_circle do |event|
    event.channel.send_file(get_user_circular_avatar(event.user.id), filename: "You.png")
  end

  BOT.command :import_season_one do |event|
    break unless event.user.id.host?

    season_name = legacy_prompt(event, 'Season 1 name?')

    player_rows = []
    loop do
      member_text = legacy_prompt(event, 'Give a user mention, user id, or display name for a Season 1 player.')
      member = legacy_member(event, member_text)
      unless member
        event.respond("I couldn't find that server member.")
        next
      end

      confessional_id = legacy_snowflake(legacy_prompt(event, "Confessional channel for **#{member.display_name}**? Mention it, paste the id, or leave blank."))
      submissions_id = legacy_snowflake(legacy_prompt(event, "Submissions channel for **#{member.display_name}**? Mention it, paste the id, or leave blank."))
      player_rows << {
        user_id: member.id,
        name: member.display_name,
        confessional: confessional_id,
        submissions: submissions_id,
        status: 'Out',
        tribe_role_id: nil,
        rank: nil
      }

      break if legacy_yes?(legacy_prompt(event, 'Done adding players?'))
    end

    tribe_rows = []
    event.respond('Tribe sorting phase.')
    loop do
      role_text = legacy_prompt(event, 'Give a tribe role mention/id/name, or leave blank if there are no more tribes.')
      break if legacy_blank?(role_text)

      role_id = legacy_snowflake(role_text)
      role = role_id.positive? ? event.server.role(role_id) : event.server.roles.find { |server_role| server_role.name.downcase.include?(role_text.downcase) }
      unless role
        event.respond("I couldn't find that role.")
        next
      end

      camp_id = legacy_snowflake(legacy_prompt(event, "Camp channel for **#{role.name}**? Mention it, paste the id, or leave blank."))
      challenge_id = legacy_snowflake(legacy_prompt(event, "Challenge channel for **#{role.name}**? Mention it, paste the id, or leave blank."))
      voice_id = legacy_snowflake(legacy_prompt(event, "Voice channel for **#{role.name}**? Paste the id or leave blank."))
      tribe_rows << {
        name: role.name,
        role_id: role.id,
        channel_id: camp_id,
        cchannel_id: challenge_id,
        vchannel_id: voice_id
      }
    end

    player_rows.each do |player_row|
      next if tribe_rows.empty?

      tribe_text = legacy_prompt(event, "Which tribe was **#{player_row[:name]}** on? Give tribe name/role id, or leave blank.")
      next if legacy_blank?(tribe_text)

      tribe_row = tribe_rows.find { |row| row[:role_id] == legacy_snowflake(tribe_text) || row[:name].downcase.include?(tribe_text.downcase) }
      player_row[:tribe_role_id] = tribe_row[:role_id] if tribe_row
    end

    player_rows.each do |player_row|
      rank_text = legacy_prompt(event, "Rank for **#{player_row[:name]}**? Leave blank if unknown.")
      next if legacy_blank?(rank_text)

      player_row[:rank] = rank_text.to_i
      player_row[:status] = rank_text.to_i == 1 ? 'Winner' : 'Out'
    end

    player_summary = player_rows.map do |row|
      tribe_name = tribe_rows.find { |tribe_row| tribe_row[:role_id] == row[:tribe_role_id] }&.dig(:name) || 'No tribe'
      "#{row[:name]} - #{tribe_name} - #{row[:rank] ? ordinal(row[:rank]) : 'No rank'}"
    end
    event.respond("Import Season 1?\n**Season:** #{season_name}\n**Players:**\n#{player_summary.join("\n")}\n**Tribes:** #{tribe_rows.map { |row| row[:name] }.join(', ')}\nType `yes` to create these records.")
    unless legacy_yes?(event.user.await!.message.content)
      event.respond('Season 1 import cancelled.')
      break
    end

    season = Season.find_or_initialize_by(id: 1)
    season.name = season_name
    season.save!
    tribes_by_role_id = {}
    tribe_rows.each do |row|
      tribe = Tribe.find_or_initialize_by(season_id: season.id, role_id: row[:role_id])
      tribe.assign_attributes(row)
      tribe.save!
      tribes_by_role_id[row[:role_id]] = tribe
    end
    player_rows.each do |row|
      player = Player.find_or_initialize_by(user_id: row[:user_id], season_id: season.id)
      player.name = row[:name]
      player.confessional = row[:confessional]
      player.submissions = row[:submissions]
      player.status = row[:status]
      player.rank = row[:rank]
      player.tribe_id = tribes_by_role_id[row[:tribe_role_id]]&.id
      player.save!
    end

    event.respond('Season 1 import saved.')
  end

  BOT.command :mark_old_items_played do |event|
    break unless event.user.id.host?

    unless Item.column_names.include?('played')
      event.respond('The items table does not have a `played` column yet.')
      break
    end

    items = Item.where.not(season_id: Setting.season_id)
    count = items.update_all(played: true)
    event.respond("Marked #{count} old item#{count == 1 ? '' : 's'} as played.")
  end

  BOT.command :legacy_items do |event|
    break unless event.user.id.host?

    created = []
    loop do
      season_id = legacy_prompt(event, 'Season id for this item?').to_i
      season = Season.find_by(id: season_id)
      unless season
        event.respond('Season not found.')
        next
      end

      name = legacy_prompt(event, 'Item name?')
      type = nil
      until type
        type = legacy_item_type(legacy_prompt(event, "Item type? Valid: #{DEFINED_FUNCTIONS.join(', ')}"))
        event.respond('That item type is not valid.') unless type
      end

      item = Item.create(
        season_id: season.id,
        name: name,
        code: item_code_from_name(name),
        description: 'Legacy item.',
        functions: [type],
        own_restriction: 0,
        targets: [],
        player_id: nil
      )
      item.update(played: false) if item.has_attribute?('played')
      created << item
      break unless legacy_yes?(legacy_prompt(event, 'Add another legacy item?'))
    end

    event.respond("Created legacy items:\n#{created.map { |item| "Season #{item.season_id}: #{item.name} (#{item.functions.join(', ')})" }.join("\n")}")
  end

  BOT.command :legacy_item_plays do |event|
    break unless event.user.id.host?

    items = Item.where.not(season_id: Setting.season_id).order(:season_id, :name).to_a
    if items.empty?
      event.respond('No legacy items found outside the latest season.')
      break
    end

    loop do
      event.respond("Legacy items:\n#{items.first(40).map { |item| "**#{item.id}** - S#{item.season_id} #{item.name} (#{Array(item.functions).join(', ')})" }.join("\n")}")
      item = Item.find_by(id: legacy_prompt(event, 'Which item id do you want to sort? Leave blank to stop.').to_i)
      break unless item && item.season_id != Setting.season_id

      owner = legacy_player(item.season_id, legacy_prompt(event, "Who owned/played **#{item.name}**? Give castaway name or mention/id."))
      unless owner
        event.respond("I couldn't find exactly one player for that owner.")
        next
      end

      targets = []
      target_text = legacy_prompt(event, 'Who was it played on? Separate multiple names with commas, or leave blank.')
      unless legacy_blank?(target_text)
        target_text.split(',').each do |piece|
          target = legacy_player(item.season_id, piece.strip)
          targets << target.id if target
        end
      end

      item.update({ player_id: owner.id, targets: targets }.merge(legacy_played_attributes(item)))
      record_event("item_played#{targets.empty? ? '' : ":details= on #{targets.map { |id| Player.find_by(id: id)&.name }.compact.join(', ')}"}", player: owner, item: item)
      event.respond("Sorted **#{item.name}** as played by **#{owner.name}**#{targets.empty? ? '' : " on #{targets.map { |id| Player.find_by(id: id)&.name }.compact.join(', ')}"}.")
      break unless legacy_yes?(legacy_prompt(event, 'Sort another legacy item play?'))
    end

    event.respond('Legacy item play sorting finished.')
  end
end
