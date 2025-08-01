class Sunny

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

  BOT.command :test do |event|
    event.channel.send_file(get_user_circular_avatar(event.user.id), filename: "You.png")
  end

  BOT.command :draft do |event|
    dead_color = '#551c1c'
    dead_background = 'red'
    base = %Q(
  <table class="table table-warning">
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
  #{SpectatorGame::Draft.where(season_id: 2).sort_by { |draft| draft.score }.map do |draft|
%Q(
    <tr>
      <th scope="row">#{BOT.user(draft.user_id).on(ALVIVOR_ID).display_name}</th>
      <td style="#{ALIVE.include?(Player.find_by(id: draft.winner_pick).status) ? '' : "background-color: #{dead_background}; color: #{dead_color};"}">#{Player.find_by(id: draft.winner_pick).name}</td>
      <td style="#{ALIVE.include?(Player.find_by(id: draft.pick_1).status) ? '' : "background-color: #{dead_background}; color: #{dead_color};"}">#{Player.find_by(id: draft.pick_1).name}</td>
      <td style="#{ALIVE.include?(Player.find_by(id: draft.pick_2).status) ? '' : "background-color: #{dead_background}; color: #{dead_color};"}">#{Player.find_by(id: draft.pick_2).name}</td>
      <td style="#{ALIVE.include?(Player.find_by(id: draft.pick_3).status) ? '' : "background-color: #{dead_background}; color: #{dead_color};"}">#{Player.find_by(id: draft.pick_3).name}</td>
      <td>#{draft.score}</td>
    </tr>)
  end.join('')}
  </tbody>
</table>)
    event.channel.send_file(html_to_image(base), filename: 'image.png')
  end
end