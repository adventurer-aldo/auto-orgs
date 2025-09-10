class Sunny

  @fibbs = {
  1 => ["Twunks", "Butter", "Bagels", "Hot Dogs", "Lemonade"],
  2 => ["Ghost named Idan", "Overdose on bath salts", "Demon", "evil spirit", "Discord Admin"],
  3 => ["The skin of fallen enemies", "artificial intelligence", "Hair", "Wood", "recycled video game consoles"],
  4 => ["100,000", "35,000", "50,000", "6,700", "65,160"],
  5 => ["the dumbest", "alien", "attractive", "left-handed children", "ugly"],
  6 => ["Unclothed", "bathroom", "death", "partial nudity", "shower scene"],
  7 => ["Social Credit points", "birds", "horses", "ducks", "donkeys"],
  8 => ["Sit alone in the shower thinking", "Sleep", "traumatized", "goon", "watch a baby cry"],
  9 => ["DNA", "at home technology", "braind", "a hot tub", "bugs"],
  10 => ["The Fallen Ice King", "Laughing Man", "The Ghostbusters", "The Bad Guy", "The Panty Snatcher"],
  11 => ["Breaking and entering", "absinthe", "pickles", "drugs", "magic mushrooms"],
  12 => ["Celiochromatysis syrup", "iced tea", "sunscreen", "Vaseline", "Flavored poop"],
  13 => ["Bass clef", "phone", "perfect pitch", "Baby Shark", "G6"]
}


  BOT.command :fibb do |event|
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "FirstQuestion", options: @fibbs[1].map { |fibb| { label: fibb, value: fibb } })
    end
    event.channel.send_message("**1st Question:**\nBen and Jerry only started making ice cream because it was too expensive to make __\\_\\_\\_\\_\\_.", false, nil, nil, nil, nil, view)
  end

end