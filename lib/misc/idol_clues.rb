class Sunny
  # Extra Vote
  BOT.command(:earth_apples, description: 'Clue.') do |event|
    event.respond("The Sunchokes are not the only vegetables referred to as earth apples, and not in english... Who else is there?")
  end

  BOT.command(:earth_apple, description: 'Clue.') do |event|
    event.respond("The Sunchokes are not the only vegetables referred to as earth apples, and not in english... Who else is there?")
  end

  BOT.command(:potatoes, description: 'Clue.') do |event|
    event.respond("The garden of Alvivor is constantly weeding out the vegetables that can't survive its harsh conditions. But from time to time, clues may be planted in some places that tell you how to survive. At the bottom right of an image, what advice did it give you?")
  end

  BOT.command(:check_the_roles, description: 'Clue.') do |event|
    event.respond("Name the second, first and then the second seedling to have been eliminated from Alvivor.")
  end

  BOT.command(:joey_sparky_joey, description: 'Clue.') do |event|
    event.respond("Attach ? branch to a tree, and a?other ?hall grow ?here it has be?n attached... ?oots don't just belong underground.")
  end
  
  BOT.command(:answer, description: 'Clue.') do |event|
    event.respond("My opposite is...")
  end

  # Extra Vote
  BOT.command(:carl_bot, description: 'Clue.') do |event|
    event.respond("An `extra` is the first word that comes to mind when seeing this one. Mee6 is a welcoming one. In the garden of Alvivor, those who can't survive are weeded out.")
  end
  
  BOT.command(:extra, description: 'Clue.') do |event|
    event.respond("To survive being weeded out, you must manage your resources smartly. For the one who grants you most of your nutrients needed for your survival is above you. Claim their name.")
  end
  
  BOT.command(:sun, description: 'Clue.') do |event|
    event.respond("The ?iggest... n?, the largest star, wh? ?hines down upon us. ?hank you.")
  end

  BOT.command(:boost, description: 'Clue.') do |event|
    event.respond("To find that which you seek, do not take your first step. Take all the second, third and fourth steps together, in order.")
  end
end