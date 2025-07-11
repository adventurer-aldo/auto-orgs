=begin

class Sunny
  BOT.command :test do |event|
    image_file = Tempfile.new(["output", ".png"])
    MiniMagick::Tool::Convert.new do |convert|
      convert.size "300x100"
      convert.xc "white"
      convert.fill "black"
      convert.gravity "center"
      convert.pointsize 40
      convert.annotate "0", "Hayden"
      convert << image_file.path
    end
    BOT.channel(HOST_CHAT).send_file(image_file)
  end

end

=end