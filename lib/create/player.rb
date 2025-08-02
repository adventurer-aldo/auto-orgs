class Sunny
  BOT.command :players, description: 'Registers the user as a new player in the current season.' do |event|
    break unless HOSTS.include? event.user.id

    cast = if event.message.role_mentions.size.positive?
             event.message.role_mentions.first.members
           else
             event.message.mentions.map { |user| user.on(event.server) }
           end

    event.respond("You didn't mention enough players!") unless cast.size > 0
    break unless cast.size > 0

    cast.each do |person|
      player = Player.create(user_id: person.id, name: person.display_name, season_id: Setting.last.season,
      confessional: event.server.create_channel(
          "#{person.display_name}-confessional",
          parent: CONFESSIONALS,
          topic: "#{person.display_name}'s Confessional. Talk to the spectators about your game here!",
          permission_overwrites: [Discordrb::Overwrite.new(person.id, type: 'member', allow: 3072),
          TRUE_SPECTATE, DENY_EVERY_SPECTATE]).id,
      submissions: event.server.create_channel("#{person.display_name}-submissions",
          parent: CONFESSIONALS,
          topic: 'Your Submissions channel. Submit challenge scores, check your inventory and play your items!',
          permission_overwrites: [Discordrb::Overwrite.new(person.id, type: 'member', allow: 3072),
          DENY_EVERY_SPECTATE]).id)

      person.on(event.server).add_role(CASTAWAY)
      person.on(event.server).remove_role(SPECTATOR)
      person.on(event.server).remove_role(TRUSTED_SPECTATOR)

      BOT.channel(player.confessional).sort_after(BOT.channel(PLAYING_SPLITTER))
      BOT.channel(player.submissions).sort_after(BOT.channel(player.confessional))
      BOT.send_message(player.confessional, "**Welcome to your confessional, <@#{person.id}>**\nThis is where you'll be talking about your game and the spectators will get a peek at your current mindset!")
      BOT.send_message(player.submissions, "**Welcome to your submissions channel!**\nHere you'll be putting your challenge scores, play, trade, receive items and submit your votes.\n\nTo start things off, check your inventory with `!help`!")
    end
    return 'The cast has been selected!'
  end
end