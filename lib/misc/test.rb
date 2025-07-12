class Sunny
  BOT.command :test do |event, *args|
    parch = Tempfile.new(["parchment", ".jpg"])
    parch.write URI.parse(PARCHMENT).read
    parch.rewind

    color = PARCHMENT_COLORS.sample

    angle = rand(-30..30)
    
    base = MiniMagick::Image.open(parch.path)
    image_file = Tempfile.new(["text", ".png"])
    
    MiniMagick::Tool.new("convert") do |convert|
      convert.size "4000x4000"
      convert.xc "none"
      convert.fill color
      convert.stroke color
      convert.strokewidth 5
      convert.gravity "center"
      convert.pointsize 220
      convert.font FONTS.sample
      convert.weight 'bold'
      convert.annotate "0", args.join('')
      convert << image_file.path
    end

    gamma = MiniMagick::Image.open(image_file.path).combine_options do |c|
      c.background 'none'
      c.rotate(angle)
      c.trim
    end

    if gamma.dimensions[0] > 1160
      max_width = 1160.0
      scale = [1.0, max_width / gamma.dimensions[0]].min
      new_width = (gamma.dimensions[0] * scale).round
      new_height = (gamma.dimensions[1] * scale).round

      gamma = gamma.resize("#{new_width}x#{new_height}")
    end

    result = base.composite(gamma) do |c|
      c.gravity "center"
    end

    tmp = Tempfile.new(["output", ".png"])
    result.write(tmp.path)
    BOT.channel(HOST_CHAT).send_file(tmp)
  end

end