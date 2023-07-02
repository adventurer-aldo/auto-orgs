class Sunny
  BOT.command :immunity, description: 'Grants immunity to all members of a role and the mentioned users.' do |event|
    break unless HOSTS.include? event.user.id

    players = []

    unless event.message.mentions.empty?
      event.message.mentions.each do |user|
        players << Player.find_by(user_id: user.id, season_id: Setting.last.season, status: ALIVE)
      end
    end

    unless event.message.role_mentions.empty?
      event.message.role_mentions.each do |role|
        role.members.each do |member|
          players << Player.find_by(user_id: member.id, season_id: Setting.last.season, status: ALIVE)
        end
      end
    end

    players.delete(nil)

    players.each do |player|
      next player if player.nil?

      player.update(status: 'Immune')
      BOT.user(player.user_id).on(event.server).add_role(IMMUNITY)
    end

    if players.empty?
      event.respond('No players were found...')
    else
      event.respond('Immunity was given!')
    end
    return

  end
end
