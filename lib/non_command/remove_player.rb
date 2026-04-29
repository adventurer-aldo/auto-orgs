class Sunny
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
          if alliance.reload.associations.size < 3 || (alliance.reload.associations.size == loser.tribe.players.size && Setting.game_stage == 1)
            channel.parent = Setting.archive_category
            BOT.send_message(channel.id, ':ballot_box_with_check: **This alliance no longer serves a purpose. This channel has been archived!**')
            channel.permission_overwrites.each do |role, _perms|
              unless role == Setting.everyone_role_id || alvivor_server.role(role).nil? == false
                channel.define_overwrite(alvivor_server.member(role), 1088, 2048)
              end
            end
            alliance.destroy
          else
            BOT.send_message(channel.id, ":broken_heart: **#{loser.name} removed...**")
            channel.permission_overwrites.each do |role, _perms|
              unless role == Setting.everyone_role_id || alvivor_server.role(role).nil? == false
                unless role == loser.user_id
                  channel.define_overwrite(alvivor_server.member(role), 3072, 0)
                else
                  channel.define_overwrite(alvivor_server.member(loser.user_id), 0, 3072)
                end
              end

            end
          end
        rescue ActiveRecord::RecordNotUnique
          channel = BOT.channel(alliance.channel_id)
          channel.parent = Setting.archive_category
          BOT.send_message(channel.id, ':ballot_box_with_check: **This channel has been archived!**')
          channel.permission_overwrites.each do |role, _perms|
            unless role == Setting.everyone_role_id || alvivor_server.role(role).nil? == false
              channel.define_overwrite(alvivor_server.member(role), 1088, 2048)
            end
          end
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
    BOT.channel(1125132585882898462).send_file(get_draft_image, filename: 'Draft.png')
    # BOT.channel(1393731026882269398).send_file(get_eliminator_image, filename: "Eliminator.png")
  end
end
