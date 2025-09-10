class Sunny

  @fibbs = {
  1 => ["twunks", "butter", "bagels", "hot dogs", "lemonade"],
  2 => ["ghost named Idan", "overdose on bath salts", "demon", "evil spirit", "discord Admin", "Ouija board"],
  3 => ["the skin of fallen enemies", "artificial intelligence", "hair", "Wood", "recycled video game consoles", "human hair"],
  4 => ["100,000", "35,000", "50,000", "6,700", "65,160", "56,000"],
  5 => ["the dumbest", "alien", "attractive", "left-handed children", "ugly"],
  6 => ["unclothed", "bathroom", "death", "partial nudity", "shower scene", "toilet flushing"],
  7 => ["Social Credit points", "birds", "horses", "ducks", "donkeys", "geese"],
  8 => ["sit alone in the shower thinking", "sleep", "traumatized", "goon", "watch a baby cry", "listen to music"],
  9 => ["DNA", "at home technology", "braind", "a hot tub", "bugs", "cockroaches"],
  10 => ["Fallen Ice King", "Laughing Man", "Ghostbusters", "Bad Guy", "Panty Snatcher", "Tickler"],
  11 => ["Breaking and entering", "absinthe", "pickles", "drugs", "magic mushrooms", "heroin"],
  12 => ["Celiochromatysis syrup", "iced tea", "sunscreen", "vaseline", "flavored poop"],
  13 => ["bass clef", "phone", "perfect pitch", "Baby Shark", "G6", "baby shower"]
}

  @questions = [
  "Ben and Jerry only started making ice cream because it was too expensive to make ﹍﹍﹍﹍﹍﹍.",
  "In 2012, a teenager from Weslaco, Texas claimed the reason he stabbed his friend was because a ﹍﹍﹍﹍﹍﹍ made him do it.",
  "A science student in Nepal has created an innovative solar panel that is far cheaper to make than a traditional solar panel, because it's made with ﹍﹍﹍﹍﹍﹍.",
  "According to Forbes, the average income for an “ice cream taster” is $﹍﹍﹍﹍﹍﹍ a year.",
  "According to a University of Jena study, the people who have the most memorable faces are ﹍﹍﹍﹍﹍﹍ people.",
  "*Psycho* was the first American movie to show a ﹍﹍﹍﹍﹍﹍.",
  "Instead of having guard dogs, police in rural parts of China's Xinjiang Province use ﹍﹍﹍﹍﹍﹍.",
  "According to a University of Barcelona study, surprisingly, 5% of people have absolutely no emotional response when they ﹍﹍﹍﹍﹍﹍.",
  "The Backyard Brains company sells a device that lets you control ﹍﹍﹍﹍﹍﹍ with your mobile phone.",
  "During the mid to late-nineties, the town of Glastonbury was on a manhunt for the odd house intruder known as “The ﹍﹍﹍﹍﹍﹍.”",
  "For a story he was reporting on in 1955, Dan Rather tried ﹍﹍﹍﹍﹍﹍ for the first time.",
  "Although gross, chemist Sir Robert Cheseborough claimed he ate a spoonful of his invention, ﹍﹍﹍﹍﹍﹍, every day.",
  "CELEBRITY TWEET! 12:44 AM - 10 Dec 2013 @SimonCowell Tweeted: “Still not sure what a ﹍﹍﹍﹍﹍﹍ is.”"
]


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
      BOT.channel(player.submissions).send_embed do |embed|
        embed.title = "List of your answers"
        embed.description = player.fibbages.order(question_no: :asc).map { |fibb| "**#{fibb.question_no}.** #{@questions[fibb.question_no - 1]}\n**Answer:** #{fibb.value}" }.join("\n\n")
        embed.color = event.user.on(ALVIVOR_ID).color
      end

    end
  end

  BOT.command :fibb do |event|
    break unless event.user.id.host?
    chan = event.channel
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "FirstQuestion", options: @fibbs[1].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**1st Question:**\nBen and Jerry only started making ice cream because it was too expensive to make ﹍﹍﹍﹍﹍﹍.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "SecondQuestion", options: @fibbs[2].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**2nd Question:**\nIn 2012, a teenager from Weslaco, Texas claimed the reason he stabbed his friend was because a ﹍﹍﹍﹍﹍﹍ made him do it.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "ThirdQuestion", options: @fibbs[3].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**3rd Question:**\nA science student in Nepal has created an innovative solar panel that is far cheaper to make than a traditional solar panel, because it’s made with ﹍﹍﹍﹍﹍﹍.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "FourthQuestion", options: @fibbs[4].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**4th Question:**\nAccording to Forbes, the average income for an “ice cream taster” is $﹍﹍﹍﹍﹍﹍ a year.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "FifthQuestion", options: @fibbs[5].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**5th Question:**\nAccording to a University of Jena study, the people who have the most memorable faces are ﹍﹍﹍﹍﹍﹍ people.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "SixthQuestion", options: @fibbs[6].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**6th Question:**\n*Psycho* was the first American movie to show a ﹍﹍﹍﹍﹍﹍.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "SeventhQuestion", options: @fibbs[7].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**7th Question:**\nInstead of having guard dogs, police in rural parts of China’s Xinjiang Province use ﹍﹍﹍﹍﹍﹍.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "EighthQuestion", options: @fibbs[8].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**8th Question:**\nAccording to a University of Barcelona study, surprisingly, 5% of people have absolutely no emotional response when they ﹍﹍﹍﹍﹍﹍.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "NinthQuestion", options: @fibbs[9].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**9th Question:**\nThe Backyard Brains company sells a device that lets you control ﹍﹍﹍﹍﹍﹍ with your mobile phone.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "TenthQuestion", options: @fibbs[10].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**10th Question:**\nDuring the mid to late-nineties, the town of Glastonbury was on a manhunt for the odd house intruder known as “The ﹍﹍﹍﹍﹍﹍.”", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "EleventhQuestion", options: @fibbs[11].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**11th Question:**\nFor a story he was reporting on in 1955, Dan Rather tried ﹍﹍﹍﹍﹍﹍ for the first time.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "TwelfthQuestion", options: @fibbs[12].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**12th Question:**\nAlthough gross, chemist Sir Robert Cheseborough claimed he ate a spoonful of his invention, ﹍﹍﹍﹍﹍﹍, every day.", false, nil, nil, nil, nil, view)

    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(custom_id: "ThirteenthQuestion", options: @fibbs[13].map { |fibb| { label: fibb, value: fibb } })
    end
    chan.send_message("**13th Question:**\nCELEBRITY TWEET! 12:44 AM - 10 Dec 2013 @SimonCowell Tweeted: “Still not sure what a ﹍﹍﹍﹍﹍﹍ is.”", false, nil, nil, nil, nil, view)
  end

end