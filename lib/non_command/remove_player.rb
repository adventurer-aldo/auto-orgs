class Sunny
  def self.user_overwrite?(server, overwrite_id)
    overwrite_id != Setting.everyone_role_id && server.role(overwrite_id).nil?
  end

  def self.remove_alliance_member_permissions(channel, server, user_id)
    channel.permission_overwrites.each do |overwrite_id, _perms|
      next unless user_overwrite?(server, overwrite_id)

      member = server.member(overwrite_id)
      next unless member

      if overwrite_id == user_id
        channel.delete_overwrite(member)
      else
        channel.define_overwrite(member, 3072, 0)
      end
    end
  end

  def self.archive_alliance_channel(channel, server)
    channel.parent = Setting.archive_category
    BOT.send_message(channel.id, ':ballot_box_with_check: **This alliance no longer serves a purpose. This channel has been archived!**')
    channel.permission_overwrites.each do |overwrite_id, _perms|
      next unless user_overwrite?(server, overwrite_id)
      member = server.member(overwrite_id)
      next unless member

      channel.define_overwrite(member, 1088, 2048)
    end
  end

  def self.alliance_no_longer_serves_purpose?(alliance, tribe)
    alliance.reload
    remaining_players = alliance.associations.map(&:player).compact
    return true if remaining_players.size <= 2
    return false unless tribe

    tribe_player_ids = tribe.players.where(season_id: Setting.season_id, status: ALIVE).map(&:id).sort
    remaining_player_ids = remaining_players.map(&:id).sort
    tribe_player_ids == remaining_player_ids
  end

  def self.eliminate(loser)
    Buddy.all.update(can_change: true)
    rank = Player.where(season_id: Setting.season_id, status: ALIVE).size
    tribe = loser.tribe
    alvivor_server = BOT.server(Setting.server_id)
    if Setting.game_stage == 1
      loser.update(status: 'Jury', rank:)
      user = BOT.user(loser.user_id).on(alvivor_server)
      user.remove_role(tribe.role_id) if tribe
      user.remove_role(Setting.exile_role_id) if Setting.exile_role_id.positive?
      user.remove_role(Setting.castaway_role_id)
      user.add_role(Setting.jury_role_id)
      BOT.channel(Setting.jury_channel_id).send_message("Welcome in the newest member of the jury, #{BOT.user(loser.user_id).mention}...")
    else
      loser.update(status: 'Out', rank:)
      user = BOT.user(loser.user_id).on(alvivor_server)

      user.remove_role(tribe.role_id) if tribe
      user.remove_role(Setting.exile_role_id) if Setting.exile_role_id.positive?
      user.remove_role(Setting.castaway_role_id)
      user.add_role(Setting.prejury_role_id)
    end

    alliances = loser.alliances
    if !alliances.empty?
      alliances.each do |alliance|
        begin
          alliance.associations.destroy_by(player_id: loser.id)
          channel = BOT.channel(alliance.channel_id)
          remove_alliance_member_permissions(channel, alvivor_server, loser.user_id)
          if alliance_no_longer_serves_purpose?(alliance, tribe)
            archive_alliance_channel(channel, alvivor_server)
            alliance.destroy
          else
            BOT.send_message(channel.id, ":broken_heart: **#{loser.name} removed...**")
          end
        rescue ActiveRecord::RecordNotUnique
          channel = BOT.channel(alliance.channel_id)
          remove_alliance_member_permissions(channel, alvivor_server, loser.user_id)
          archive_alliance_channel(channel, alvivor_server)
          alliance.destroy
        end
      end
    end
    addendum = case rank
               when 1
                 'st'
               when 2
                 'nd'
               when 3
                 'rd'
               else
                 'th'
               end
    conf = BOT.channel(loser.confessional)
    conf.name = "#{rank}#{addendum}-" + conf.name
    if Setting.game_stage == 1
      conf.sort_after(BOT.channel(Setting.jury_splitter_channel_id))
    else
      conf.sort_after(BOT.channel(Setting.prejury_splitter_channel_id))
    end
    subm = BOT.channel(loser.submissions)
    subm.name = "#{rank}#{addendum}-" + subm.name
    subm.sort_after(conf)
    Player.where(status: ALIVE, season_id: Setting.season_id).update(status: 'In')
    alvivor_server.role(Setting.immunity_role_id).members.each { |immune| immune.on(alvivor_server).remove_role(Setting.immunity_role_id) }
    BOT.channel(Setting.spectator_draft_channel_id).send_file(get_draft_image, filename: 'Draft.png')
    # BOT.channel(Setting.spectator_elimination_channel_id).send_file(get_eliminator_image, filename: "Eliminator.png")
  end
end
