class Sunny
  BOT.command :prune, description: 'Cleans up a channel.' do |event|
    break unless event.user.id.host?

    suppress_message_logging do
      event.channel.prune(100)
    end
    return
  rescue StandardError => e
    event.respond("Prune failed: #{e.message}")
  end

  BOT.command :update, description: 'Updates the item list so that new codes can be found.' do |event|
    break unless event.user.id.host?

    make_item_commands
    event.respond('The items list has been updated!')
  end

  def self.reset_channel_ids(season)
    tribe_channels = Tribe.where(season_id: season.id).flat_map { |tribe| [tribe.channel_id, tribe.vchannel_id, tribe.cchannel_id] }
    council_channels = Council.where(season_id: season.id).map(&:channel_id)
    (tribe_channels + council_channels).compact.uniq
  end

  def self.reset_summary(season)
    councils = Council.where(season_id: season.id)
    player_ids = Player.where(season_id: season.id).select(:id)
    item_ids = Item.where(season_id: season.id).select(:id)
    tribe_ids = Tribe.where(season_id: season.id).select(:id)
    associated_records =
      Buddy.where(player_id: player_ids).count +
      Challenges::Individual.where(player_id: player_ids).count +
      Challenges::Fibbage.where(player_id: player_ids).count +
      Challenges::Potato.where(player_id: player_ids).count +
      Challenges::Tribal.where(tribe_id: tribe_ids).count +
      Challenges::Participant.where(player_id: player_ids).count +
      Challenges::Battleships::Ship.where(tribe_id: tribe_ids).count +
      Challenges::Battleships::Damage.where(tribe_id: tribe_ids).count +
      Alliances::Association.where(player_id: player_ids).count +
      Alliances::Group.where(season_id: season.id).count +
      SpectatorGame::Draft.where(season_id: season.id).count +
      SpectatorGame::Elimination.where(season_id: season.id).count +
      SpectatorGame::Bootlist.where(season_id: season.id).count +
      Event.where(player_id: player_ids).or(Event.where(item_id: item_ids)).count
    <<~TEXT
      **Reset Season #{season.id}?**
      This will delete:
      **Players:** #{Player.where(season_id: season.id).count}
      **Items:** #{Item.where(season_id: season.id).count}
      **Episodes:** #{Episode.where(season_id: season.id).count}
      **Councils:** #{councils.count}
      **Votes:** #{Vote.where(council_id: councils.select(:id)).count}
      **Tribes:** #{Tribe.where(season_id: season.id).count}
      **Associated player/game/event rows:** #{associated_records}
      **Discord Channels:** #{reset_channel_ids(season).size} tribe/council channel#{reset_channel_ids(season).size == 1 ? '' : 's'}

      Type `yes` to confirm.
    TEXT
  end

  BOT.command :reset, description: 'Deletes current season data after confirmation.' do |event|
    break unless event.user.id.host?

    season = Setting.season
    unless season
      event.respond('There is no current season configured.')
      break
    end

    event.respond(reset_summary(season))
    confirmation = event.user.await!(timeout: 60)
    unless confirmation && Setting.confirmation?(confirmation.message.content)
      event.respond('Reset cancelled.')
      break
    end

    reset_channel_ids(season).each do |channel_id|
      BOT.channel(channel_id)&.delete
    rescue StandardError
      nil
    end

    councils = Council.where(season_id: season.id)
    player_ids = Player.where(season_id: season.id).select(:id)
    item_ids = Item.where(season_id: season.id).select(:id)
    tribe_ids = Tribe.where(season_id: season.id).select(:id)
    Event.where(player_id: player_ids).or(Event.where(item_id: item_ids)).destroy_all
    SpectatorGame::Draft.where(season_id: season.id).destroy_all
    SpectatorGame::Elimination.where(season_id: season.id).destroy_all
    SpectatorGame::Bootlist.where(season_id: season.id).destroy_all
    Alliances::Association.where(player_id: player_ids).destroy_all
    Alliances::Group.where(season_id: season.id).destroy_all
    Buddy.where(player_id: player_ids).destroy_all
    Challenges::Individual.where(player_id: player_ids).destroy_all
    Challenges::Fibbage.where(player_id: player_ids).destroy_all
    Challenges::Potato.where(player_id: player_ids).destroy_all
    Challenges::Tribal.where(tribe_id: tribe_ids).destroy_all
    Challenges::Participant.where(player_id: player_ids).destroy_all
    Challenges::Battleships::Ship.where(tribe_id: tribe_ids).destroy_all
    Challenges::Battleships::Damage.where(tribe_id: tribe_ids).destroy_all
    Vote.where(council_id: councils.select(:id)).destroy_all
    councils.destroy_all
    Item.where(season_id: season.id).destroy_all
    Episode.where(season_id: season.id).destroy_all
    Player.where(season_id: season.id).destroy_all
    Tribe.where(season_id: season.id).destroy_all
    Setting.tribes = []
    make_item_commands

    event.respond("Season #{season.id} has been reset.")
  end
end
