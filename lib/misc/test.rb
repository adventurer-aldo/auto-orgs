class Sunny

  BOT.command :to_html do |event, *args|
    event.channel.send_file(html_to_image("<div style=\"
    background-color: red;
    color: white;
    padding: 20px;
    border: 1px solid #ccc;
    border-radius: 5px;
    text-align: center;
    font-family: Arial, sans-serif;
    font-size: 18px;
    font-weight: bold;
\">
    We got this going good
</div>"), filename: 'image.png')
  end
end