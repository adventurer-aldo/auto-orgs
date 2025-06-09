class Sunny

  BOT.command :unbuddy do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season)
    buddies = player.buddies

    break unless event.channel.id == player.confessional || event.channel.id == player.submissions

    acceptable_mentions = event.mentions.uniq.filter { |user| player.buddies.where(user_id: user.id).exists? }
    if acceptable_mentions.empty?
      event.respond("None of the people you mentioned is your confessional buddy!")
    else
      acceptable_mentions.each do |ex_buddy|
        BOT.channel(player.confessional).delete_overwrite(ex_buddy)
      end
      event.respond("**#{acceptable_mentions.map(&:global_name).join('**, **')}** have stopped being your confessional buddies...")
    end
  end
  
  BOT.command :buddy do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season)
    buddies = player.buddies

    break unless event.channel.id == player.confessional || event.channel.id == player.submissions

    # Check if you can get new buddies.
    if buddies.map(&:can_change).include?(true) || buddies.size < 2
      if buddies.size < 2
        acceptable_mentions = event.message.mentions.uniq.filter { |user| user.on(ALVIVOR_ID).role?(TRUSTED_SPECTATOR) }[0..1]

        event.respond "You didn't mention anybody eligible!" if acceptable_mentions.size < 1
        return if acceptable_mentions.size < 1

        acceptable_mentions.each do |buddy|
          new_buddy = Buddy.create(user_id: buddy.id, player_id: player.id)
          allow = Discordrb::Permissions.new [:read_messages, :send_messages ]
          deny = Discordrb::Permissions.new
          BOT.channel(player.confessional).define_overwrite(BOT.user(new_buddy.user_id), allow, deny)
        end

        # If the number of buddies exceeds 2, delete the extras.
        if (acceptable_mentions + buddies).size > 2
          (acceptable_mentions.map(&:id) + buddies.map(&:user_id))[2..-1].each do |old_buddy_user_id|
            Buddy.destroy_by(player_id: player.id, user_id: old_buddy_user_id)
            BOT.channel(player.confessional).delete_overwrite(old_buddy_user_id)
          end
        end
        event.respond("**#{acceptable_mentions.map(&:global_name).join('**, **')}** have been added as your confessional buddies!")
      end
    else
      event.respond("You can't change your confessional buddies until the next cycle!")
    end
  end
end