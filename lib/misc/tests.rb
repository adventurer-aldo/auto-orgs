class Sunny

    BOT.command :connected do |event|
        ActiveRecord::Base.connected?.to_s
    end

end