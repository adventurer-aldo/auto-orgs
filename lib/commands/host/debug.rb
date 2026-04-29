class Sunny
  BOT.command :debug do |event, *args|
    break unless event.user.id.host?

    value = args.first.to_s.downcase
    self.debug_mode = case value
                      when 'on', 'true', 'yes', '1'
                        true
                      when 'off', 'false', 'no', '0'
                        false
                      else
                        !debug_mode?
                      end

    event.respond("Debug mode is now **#{debug_mode? ? 'ON' : 'OFF'}**.")
  end
end
