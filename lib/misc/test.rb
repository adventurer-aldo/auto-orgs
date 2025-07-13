class Sunny

  BOT.command :to_html do |event, *args|
    event.channel.send_file(html_to_image("<table class=\"container table table-striped table-sm table-secondary table-bordered border-dark \">
    <thead class=\"table-dark\">
      <tr>
        <th scope=\"col\">Spectators</th><th>Winner Pick</th><th>Pick 1</th><th>Pick 2</th><th>Pick 3</th>
      </tr>
    </thead>
    <tbody class=\"table-group-divider\">
      <tr><td>Ana</td><td>Yes</td><td>Leo</td><td>Mira</td><td>Jude</td></tr>
      <tr><td>Ben</td><td>No</td><td>Ken</td><td>Aria</td><td>Leo</td></tr>
    </tbody>
  </table>"), filename: 'image.png')
  end
end