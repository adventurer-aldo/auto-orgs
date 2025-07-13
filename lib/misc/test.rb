class Sunny
  BOT.command :test_old do |event, *args|
    event.channel.send_file generate_parchment(args.join(''))
  end
  
  BOT.command :test do |event, *args|
    image = HTML_TO_JPG_CLIENT.create_image("<head>
        <meta charset=\"utf-8\">
        <title>Bootstrap demo</title>
        <link href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css\" rel=\"stylesheet\" integrity=\"sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr\" crossorigin=\"anonymous\">
    </head>
      <table class=\"container table table-striped table-sm table-secondary table-bordered border-dark \">
        <thead class=\"table-dark\">
          <tr>
            <th scope=\"col\">Spectators</th><th>Winner Pick</th><th>Pick 1</th><th>Pick 2</th><th>Pick 3</th>
          </tr>
        </thead>
        <tbody class=\"table-group-divider\">
        #{Player.where(status: ALIVE, season: Setting.last.season).map { |player| "<tr><td>#{player.name}</td><td>Yes</td><td>Leo</td><td>Mira</td><td>Jude</td></tr>" } }
        </tbody>
      </table>
    ",
    css: "table {
        table-layout: auto !important;
        width: auto !important;
        text-align: center;
      }
      th, td {
        padding: 0.3rem !important;
        white-space: nowrap;
      }",
    google_fonts: "Roboto")

    BOT.channel(HOST_CHAT).send_message(image.url)


  end
end