class Sunny
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
      #{SpectatorGame::Elimination.where(season_id: Setting.season).map do |elim|
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

  def self.draft_castaway_avatar(player)
    return '' unless player && Shrine.storages[:store].exists?(player.image_storage_id)

    %Q(<img class="castaway-avatar" src="#{player.image_url}">)
  rescue StandardError
    ''
  end

  def self.draft_pick_cell(player, css_class, escape_html)
    return %Q(<td class="#{css_class}"></td>) unless player

    status_class = ALIVE.include?(player.status) ? '' : ' eliminated'
    %Q(
      <td class="#{css_class}#{status_class}">
        <div class="pick-wrap">
          #{draft_castaway_avatar(player)}
          <span>#{escape_html.call(player.name)}</span>
        </div>
      </td>)
  end

  def self.get_draft_image
    escape_html = ->(text) { text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;') }
    drafts = SpectatorGame::Draft.where(season_id: Setting.season).sort_by { |draft| draft.score || 0 }
                                 .select { |draft| !draft.winner_pick.nil? && !draft.pick_1.nil? && !draft.pick_2.nil? && !draft.pick_3.nil? }

    rows = drafts.map do |draft|
      winner = Player.find_by(id: draft.winner_pick)
      pick_1 = Player.find_by(id: draft.pick_1)
      pick_2 = Player.find_by(id: draft.pick_2)
      pick_3 = Player.find_by(id: draft.pick_3)
      spectator = BOT.user(draft.user_id).on(Setting.server_id).display_name

      %Q(
        <tr>
          <td class="spectator">#{escape_html.call(spectator)}</td>
          #{draft_pick_cell(winner, 'winner', escape_html)}
          #{draft_pick_cell(pick_1, 'pick', escape_html)}
          #{draft_pick_cell(pick_2, 'pick', escape_html)}
          #{draft_pick_cell(pick_3, 'pick', escape_html)}
          <td class="score">#{draft.score}</td>
        </tr>)
    end.join('')

    base = %Q(
      <main class="draft-page">
        <section class="title-block">
          <h1>Alvivor Draft</h1>
        </section>

        <section class="table-card">
          <table>
            <thead>
              <tr>
                <th>Spectator</th>
                <th>Winner Pick</th>
                <th>Pick 1</th>
                <th>Pick 2</th>
                <th>Pick 3</th>
                <th>Score</th>
              </tr>
            </thead>
            <tbody>
              #{rows}
            </tbody>
          </table>
        </section>
      </main>

      <style>
        body {
          background: #fbfaf6 !important;
          color: #33483d;
          font-family: Georgia, "Times New Roman", serif;
          margin: 0;
        }

        .draft-page {
          background: #fbfaf6;
          padding: 42px;
          width: max-content;
        }

        .title-block {
          margin: 0 0 26px;
          text-align: center;
        }

        .title-block h1 {
          color: #2f563f;
          font-size: 52px;
          font-weight: 500;
          line-height: 1;
          margin: 0;
        }

        .table-card {
          background: white;
          border: 1px solid #dfe6dc;
          border-radius: 14px;
          box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
          overflow: hidden;
        }

        table {
          border-collapse: separate !important;
          border-spacing: 0 !important;
          min-width: 1040px;
          table-layout: auto !important;
          width: 100% !important;
        }

        thead {
          background: #e4ebe1;
        }

        thead th {
          border-bottom: 2px solid #cbd7c8;
          color: #385246;
          font-size: 13px;
          letter-spacing: 0.08em;
          padding: 16px !important;
          text-align: center;
          text-transform: uppercase;
          white-space: nowrap;
        }

        tbody td {
          border-bottom: 1px solid #dfe6dc;
          border-right: 1px solid #dfe6dc;
          padding: 16px !important;
          text-align: center;
          vertical-align: middle;
          white-space: nowrap;
        }

        tbody td:last-child {
          border-right: none;
        }

        tbody tr:last-child td {
          border-bottom: none;
        }

        .spectator {
          color: #2f563f;
          font-size: 20px;
          min-width: 170px;
          text-align: left;
        }

        .winner {
          color: #b78149;
          font-weight: 600;
        }

        .pick {
          color: #5c6f63;
          font-style: italic;
        }

        .score {
          color: #2f563f;
          font-size: 20px;
          font-weight: 700;
          min-width: 72px;
        }

        .pick-wrap {
          align-items: center;
          display: inline-flex;
          gap: 10px;
          justify-content: center;
        }

        .castaway-avatar {
          border: 2px solid #dfe6dc;
          border-radius: 50%;
          height: 38px;
          object-fit: cover;
          width: 38px;
        }

        .eliminated {
          background: #f4e9e3;
          color: #8f4a42;
        }
      </style>)
    html_to_image(base)
  end

  BOT.command :draft do |event|
    event.channel.send_file(Sunny.get_draft_image, filename: 'Draft.png')
  end
end
