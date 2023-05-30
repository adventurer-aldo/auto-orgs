=begin
class Sunny
  BOT.member_join do |event|
    if event.server.id == SERVER_ID
      BOT.send_message(USER_JOIN_CHANNEL, format(Setting.last.join_msg, event.user.name))
      event.user.on(SERVER_ID).add_role(963454509269532752)
    end
  end

  BOT.member_leave do |event|
    BOT.send_message(USER_JOIN_CHANNEL, format(Setting.last.leave_msg, event.user.name)) if event.server.id == SERVER_ID
  end

  BOT.command :set do |event, opera, *args|
    if HOSTS.include? event.user.id
      if opera == 'join'
        Setting.last.update(join_msg: args.join(' '))
        'Your join message has changed!'
      elsif opera == 'leave'
        Setting.last.update(leave_msg: args.join(' '))
        'Your leave message has changed!'
      else
        'There are no operators there.'
      end
    else
      'You do not have permission to use that command.'
    end
  end
end
=end
