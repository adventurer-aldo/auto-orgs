class Sunny
  def self.html_to_image(string)
    https = Net::HTTP.new(HTML_TO_PNG.host, HTML_TO_PNG.port)
    https.use_ssl = true
    request = Net::HTTP::Post.new(HTML_TO_PNG)
    request["Authorization"] = "Bearer 81b432014c9e61d77b33daae"
    request["Content-Type"] = "application/json"
    base_meta = "<head>
    <meta charset=\"utf-8\">
    <title>Bootstrap demo</title>
    <link href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css\" rel=\"stylesheet\" integrity=\"sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr\" crossorigin=\"anonymous\">
</head>
<style>  body {      background-color: #39FF14  }
  table {    table-layout: auto !important;    width: auto !important;    text-align: center;  }
  th, td {    padding: 0.3rem !important;    white-space: nowrap;  }    </style>"

    html = Base64.encode64("<head>
    <meta charset=\"utf-8\">
    <title>Bootstrap demo</title>
    <link href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css\" rel=\"stylesheet\" integrity=\"sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr\" crossorigin=\"anonymous\">
</head>
<style>
  body {
      background-color: #39FF14
  }
  table {
    table-layout: auto !important;
    width: auto !important;
    text-align: center;
  }
  th, td {
    padding: 0.3rem !important;
    white-space: nowrap;
  }
    </style>
  <table class=\"container table table-striped table-sm table-secondary table-bordered border-dark \"> <thead class=\"table-dark\"> <tr> <th scope=\"col\">Spectators</th><th>Winner Pick</th><th>Pick 1</th><th>Pick 2</th><th>Pick 3</th> </tr> </thead> <tbody class=\"table-group-divider\"> <tr><td>Ana</td><td>Yes</td><td>Leo</td><td>Mira</td><td>Jude</td></tr> <tr><td>Ben</td><td>No</td><td>Ken</td><td>Aria</td><td>Leo</td></tr> </tbody> </table>")
  BOT.channel(HOST_CHAT).send_message("<head>
    <meta charset=\"utf-8\">
    <title>Bootstrap demo</title>
    <link href=\"https://cdn.jsdelivr.net/npm/bootstrap@5.3.7/dist/css/bootstrap.min.css\" rel=\"stylesheet\" integrity=\"sha384-LN+7fdVzj6u52u30Kp6M/trliBMCMKTyK833zpbD+pXdCLuTusPj697FH4R/5mcr\" crossorigin=\"anonymous\">
</head>
<style>
  body {
      background-color: #39FF14
  }
  table {
    table-layout: auto !important;
    width: auto !important;
    text-align: center;
  }
  th, td {
    padding: 0.3rem !important;
    white-space: nowrap;
  }
    </style>
  <table class=\"container table table-striped table-sm table-secondary table-bordered border-dark \"> <thead class=\"table-dark\"> <tr> <th scope=\"col\">Spectators</th><th>Winner Pick</th><th>Pick 1</th><th>Pick 2</th><th>Pick 3</th> </tr> </thead> <tbody class=\"table-group-divider\"> <tr><td>Ana</td><td>Yes</td><td>Leo</td><td>Mira</td><td>Jude</td></tr> <tr><td>Ben</td><td>No</td><td>Ken</td><td>Aria</td><td>Leo</td></tr> </tbody> </table>")
    request.body = JSON.dump({
      "page": {
        "screenshot": {
          "captureBeyondViewport": true,
          "fullPage": true
        },
        "setContent": {
          "html": html
        }
      }
    })

    response = https.request(request)
    a = Tempfile.new(['html', '.png'])
    MiniMagick::Image.open(JSON.parse(response.read_body)['documentUrl']).transparent('#39FF14').trim().write(a.path)
    return a
  end
end