class Sunny

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
  #{SpectatorGames::Draft.where(season_id: Setting.last.season).sort_by { |draft| draft.score }.map do |draft|
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