class Sunny
  BOT.command :test do |event|
    parch = Tempfile.new(["parchment", ".jpg"])
    parch.write URI.parse(PARCHMENT).read
    parch.rewind
    
    base = MiniMagick::Image.open(parch.path)
    image_file = Tempfile.new(["output", ".png"])
    
    MiniMagick::Tool.new("convert") do |convert|
      convert.size "300x100"
      convert.xc "none"
      convert.fill "black"
      convert.gravity "center"
      convert.pointsize 100
      convert.annotate "0", "Hayden"
      convert << image_file.path
    end
    gamma = MiniMagick::Image.open(image_file.path).rotate(30).combine_options do |c|
      c.fuzz "80%"
      c.transparent "white"
    end

    result = base.composite(gamma) do |c|
      c.gravity "center"
    end
    tmp = Tempfile.new(["output", ".png"])
    result.write(tmp.path)
    BOT.channel(HOST_CHAT).send_file(tmp)
  end

end