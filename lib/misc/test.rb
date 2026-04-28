class Sunny
  BOT.command :make_parchment do |event, *args|
    break unless event.user.id.host?

    text = args.join(' ')
    text = event.user.display_name if text == ''
    event.channel.send_file(generate_parchment(text), filename: 'parchment.png')
  end

  BOT.command :test do |event, *args|
    season = args[0] ? Season.find_by(id: args[0].to_i) : Setting.season

    return event.respond('Season not found.') if season.nil?

    event.channel.send_file(Sunny.get_season_cast_image(season), filename: "season-#{season.id}.png")
  end

  def self.get_season_cast_image(season)
    players = Player.where(season_id: season.id).sort_by { |player| [player.rank.nil? ? 1 : 0, player.rank || 0, player.name] }
    season_title = season.respond_to?(:name) && season.name.to_s != '' ? "#{season.id}: #{season.name}" : season.id
    escape_html = ->(text) { text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;') }

    avatars = players.map do |player|
      user = BOT.user(player.user_id)
      avatar_url = user.avatar_url
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

  def self.get_draft_image
    dead_color = '#551c1c'
    dead_background = 'red'
    base = %Q(
  <table class="table table-primary">
  <thead class="table-dark">
    <tr>
      <th scope="col">Spectator</th>
      <th scope="col">Winner Pick</th>
      <th scope="col">Pick 1</th>
      <th scope="col">Pick 2</th>
      <th scope="col">Pick 3</th>
      <th scope="col">Score</th>
    </tr>
  </thead>
  <tbody>
  #{SpectatorGame::Draft.where(season_id: Setting.season).sort_by { |draft| draft.score }.select { |draft| !draft.winner_pick.nil? && !draft.pick_1.nil? && !draft.pick_2.nil? && !draft.pick_3.nil?}.map do |draft|
%Q(
    <tr>
      <th scope="row">#{BOT.user(draft.user_id).on(Setting.server_id).display_name}</th>
      <td style="#{ALIVE.include?(Player.find_by(id: draft.winner_pick).status) ? '' : "background-color: #{dead_background}; color: #{dead_color};"}">#{Player.find_by(id: draft.winner_pick).name}</td>
      <td style="#{ALIVE.include?(Player.find_by(id: draft.pick_1).status) ? '' : "background-color: #{dead_background}; color: #{dead_color};"}">#{Player.find_by(id: draft.pick_1).name}</td>
      <td style="#{ALIVE.include?(Player.find_by(id: draft.pick_2).status) ? '' : "background-color: #{dead_background}; color: #{dead_color};"}">#{Player.find_by(id: draft.pick_2).name}</td>
      <td style="#{ALIVE.include?(Player.find_by(id: draft.pick_3).status) ? '' : "background-color: #{dead_background}; color: #{dead_color};"}">#{Player.find_by(id: draft.pick_3).name}</td>
      <td>#{draft.score}</td>
    </tr>)
  end.join('')}
  </tbody>
</table>)
    html_to_image(base)
  end

  BOT.command :draft do |event|
    event.channel.send_file(Sunny.get_draft_image, filename: 'image.png')
  end
end
