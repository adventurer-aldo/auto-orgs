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
  10 => ["Fallen Ice King", "Laughing Man", "Ghostbusters", "Bad Guy", "Panty Snatcher"],
  11 => ["Breaking and entering", "absinthe", "pickles", "drugs", "magic mushrooms"],
  12 => ["Celiochromatysis syrup", "iced tea", "sunscreen", "Vaseline", "Flavored poop"],
  13 => ["Bass clef", "phone", "perfect pitch", "Baby Shark", "G6"]
}

  @id_map = {
    "FirstQuestion"      => 1,
    "SecondQuestion"     => 2,
    "ThirdQuestion"      => 3,
    "FourthQuestion"     => 4,
    "FifthQuestion"      => 5,
    "SixthQuestion"      => 6,
    "SeventhQuestion"    => 7,
    "EighthQuestion"     => 8,
    "NinthQuestion"      => 9,
    "TenthQuestion"      => 10,
    "EleventhQuestion"   => 11,
    "TwelfthQuestion"    => 12,
    "ThirteenthQuestion" => 13
  }

  @id_map.keys.each do |key|
    BOT.string_select(custom_id: key) do |event|
      event.defer_update

      break unless event.user.id.player?
      player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season)
      q_no = @id_map[key]
      BOT.channel(HOST_CHAT).send_message("**#{player.name}** chose **#{event.values.first}** for Question No. #{q_no}")
      BOT.channel(player.submissions).send_message("You chose **#{event.values.first}** for Question No. #{q_no}")

      Challenges::Fibbage.find_or_create_by(player_id: player.id, question_no: q_no)
                        .update(value: event.values.first)
    end
  end

  BOT.command :fibb do |event|
    chan = event.channel
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "FirstQuestion", options: @fibbs[1].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**1st Question:**\nBen and Jerry only started making ice cream because it was too expensive to make __\\_\\_\\_\\_\\_.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "SecondQuestion", options: @fibbs[2].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**2nd Question:**\nIn 2012, a teenager from Weslaco, Texas claimed the reason he stabbed his friend was because a __\\_\\_\\_\\_\\_ made him do it.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "ThirdQuestion", options: @fibbs[3].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**3rd Question:**\nA science student in Nepal has created an innovative solar panel that is far cheaper to make than a traditional solar panel, because it’s made with __\\_\\_\\_\\_\\_.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "FourthQuestion", options: @fibbs[4].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**4th Question:**\nAccording to Forbes, the average income for an “ice cream taster” is $__\_\_\_\_\_ a year.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "FifthQuestion", options: @fibbs[5].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**5th Question:**\nAccording to a University of Jena study, the people who have the most memorable faces are __\\_\\_\\_\\_\\_ people.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "SixthQuestion", options: @fibbs[6].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**6th Question:**\n*Psycho* was the first American movie to show a __\\_\\_\\_\\_\\_.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "SeventhQuestion", options: @fibbs[7].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**7th Question:**\nInstead of having guard dogs, police in rural parts of China’s Xinjiang Province use __\\_\\_\\_\\_\\_.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "EighthQuestion", options: @fibbs[8].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**8th Question:**\nAccording to a University of Barcelona study, surprisingly, 5% of people have absolutely no emotional response when they __\\_\\_\\_\\_\\_.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "NinthQuestion", options: @fibbs[9].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**9th Question:**\nThe Backyard Brains company sells a device that lets you control __\\_\\_\\_\\_\\_ with your mobile phone.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "TenthQuestion", options: @fibbs[10].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**10th Question:**\nDuring the mid to late-nineties, the town of Glastonbury was on a manhunt for the odd house intruder known as “The __\\_\\_\\_\\_\\_.”", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "EleventhQuestion", options: @fibbs[11].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**11th Question:**\nFor a story he was reporting on in 1955, Dan Rather tried __\\_\\_\\_\\_\\_ for the first time.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "TwelfthQuestion", options: @fibbs[12].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**12th Question:**\nAlthough gross, chemist Sir Robert Cheseborough claimed he ate a spoonful of his invention, __\\_\\_\\_\\_\\_, every day.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "ThirteenthQuestion", options: @fibbs[13].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**13th Question:**\nCELEBRITY TWEET! 12:44 AM - 10 Dec 2013 @SimonCowell Tweeted: “Still not sure what a __\\_\\_\\_\\_\\_ is.”", false, nil, nil, nil, nil, view)
  end

end