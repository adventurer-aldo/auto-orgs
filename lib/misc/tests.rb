class Sunny

    BOT.command :connected do |event|
        ActiveRecord::Base.connected?.to_s
    end

    BOT.command :test do |event|
        return event.user.id.player?
    end
end