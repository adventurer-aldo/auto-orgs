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

    request.body = JSON.dump({
      "page": {
        "screenshot": {
          "captureBeyondViewport": true,
          "fullPage": true
        },
        "setContent": {
          "html": Base64.encode64(base_meta + string)
        }
      }
    })

    response = https.request(request)
    a = Tempfile.new(['html', '.png'])
    MiniMagick::Image.open(JSON.parse(response.read_body)['documentUrl']).transparent('#39FF14').trim().write(a.path)
    return a
  end
end