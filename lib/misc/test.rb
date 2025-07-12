class Sunny
  BOT.command :test do |event|
    parch = Tempfile.new(["parchment", ".jpg"])
    parch.write URI.parse(PARCHMENT).read
    parch.rewind

    color = PARCHMENT_COLORS.sample

    angle = rand(-30..30)
    
    base = MiniMagick::Image.open(parch.path)
    image_file = Tempfile.new(["text", ".png"])
    
    MiniMagick::Tool.new("convert") do |convert|
      convert.size "2000x2000"
      convert.xc "none"
      convert.fill color
      convert.stroke color
      convert.strokewidth 5
      convert.gravity "center"
      convert.pointsize 220
      convert.font FONTS.sample
      convert.weight 'bold'
      convert.annotate "0", 'Castaway'
      convert << image_file.path
    end

    gamma = MiniMagick::Image.open(image_file.path)

    result = base.composite(gamma) do |c|
      c.gravity "center"
    end
    tmp = Tempfile.new(["output", ".png"])
    result.write(tmp.path)
    BOT.channel(HOST_CHAT).send_file(tmp)
  end

end