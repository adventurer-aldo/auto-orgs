class Sunny

    BOT.reaction_add(message: 965599732485476493, in: 964477790667825152, emoji: '🔴') do |event|
        event.user.on(event.server).add_role(965587182221918238)
    end

    BOT.reaction_add(message: 965599732485476493, in: 964477790667825152, emoji: '🔵') do |event|
        event.user.on(event.server).add_role(965587191029964870)
    end

    BOT.reaction_add(message: 965599732485476493, in: 964477790667825152, emoji: '🟢') do |event|
        event.user.on(event.server).add_role(965587204674056192)
    end

    BOT.reaction_remove(message: 965599732485476493, in: 964477790667825152, emoji: '🔴') do |event|
        event.user.on(event.server).remove_role(965587182221918238)
    end

    BOT.reaction_remove(message: 965599732485476493, in: 964477790667825152, emoji: '🔵') do |event|
        event.user.on(event.server).remove_role(965587191029964870)
    end

    BOT.reaction_remove(message: 965599732485476493, in: 964477790667825152, emoji: '🟢') do |event|
        event.user.on(event.server).remove_role(965587204674056192)
    end

end