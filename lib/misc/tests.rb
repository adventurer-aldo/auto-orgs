class Sunny

    BOT.command :connected, description: "Are you connected to the Database?" do |event|
        ActiveRecord::Base.connected?.to_s
    end

    BOT.command :test, description: "idk something random" do |event|
        event.respond("HsIs!")
    end
    
end