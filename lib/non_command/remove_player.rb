class Sunny
  def self.eliminate(loser, event)
    Buddy.all.update(can_change: true)
    rank = Player.where(season_id: Setting.last.season, status: ALIVE).size
    tribe = loser.tribe
    if Setting.last.game_stage == 1
      loser.update(status: 'Jury', rank:)
      user = BOT.user(loser.user_id).on(event.server)
      user.remove_role(tribe.role_id) if tribe
      user.remove_role(CASTAWAY)
      user.add_role(JURY)
    else
      loser.update(status: 'Out', rank:)
      user = BOT.user(loser.user_id).on(event.server)

      user.remove_role(tribe.role_id) if tribe
      user.remove_role(CASTAWAY)
      user.add_role(PREJURY)
    end

    alliances = loser.alliances
    if !alliances.empty?
      alliances.each do |alliance|
        begin
          alliance.associations.destroy_by(player_id: loser.id)
          channel = BOT.channel(alliance.channel_id)
          if alliance.reload.associations.size < 3 || (alliance.reload.associations.size == loser.tribe.players.size && Setting.last.game_stage == 1)
            channel.parent = Setting.last.archive_category
            BOT.send_message(channel.id, ':ballot_box_with_check: **This channel has been archived!**')
            channel.permission_overwrites.each do |role, _perms|
              unless role == EVERYONE || event.server.role(role).nil? == false
                channel.define_overwrite(event.server.member(role), 1088, 2048)
              end
            end
            alliance.destroy
          else
            BOT.send_message(channel.id, ":broken_heart: **#{loser.name} removed...**")
            channel.permission_overwrites.each do |role, _perms|
              unless role == EVERYONE || event.server.role(role).nil? == false
                unless role == loser.user_id
                  channel.define_overwrite(event.server.member(role), 3072, 0)
                else
                  channel.define_overwrite(event.server.member(loser.user_id), 0, 3072)
                end
              end

            end
          end
        rescue ActiveRecord::RecordNotUnique
          channel = BOT.channel(alliance.channel_id)
          channel.parent = Setting.last.archive_category
          BOT.send_message(channel.id, ':ballot_box_with_check: **This channel has been archived!**')
          channel.permission_overwrites.each do |role, _perms|
            unless role == EVERYONE || event.server.role(role).nil? == false
              channel.define_overwrite(event.server.member(role), 1088, 2048)
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
    if Setting.last.game_stage == 1
      conf.sort_after(BOT.channel(JURY_SPLITTER))
    else
      conf.sort_after(BOT.channel(PRE_JURY_SPLITTER))
    end
    subm = BOT.channel(loser.submissions)
    subm.name = "#{rank}#{addendum}-" + subm.name
    subm.sort_after(conf)
    Player.where(status: ALIVE, season_id: Setting.last.season).update(status: 'In')
    event.server.role(IMMUNITY).members.each { |immune| immune.on(event.server).remove_role(IMMUNITY) }
    BOT.channel(1125132585882898462).send_file(get_draft_image, filename: 'Draft.png')
    BOT.channel(1393731026882269398).send_file(get_eliminator_image, filename: "Eliminator.png")
  end
end
