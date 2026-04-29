class Sunny
  BOT.command(:set_archive) do |event, *args|
    break unless event.user.id.host?

    Setting.archive_category_id = args.join.to_i
    return "#{BOT.channel(args.join('').to_i).mention} has been set as the **Archive Category!**"
  end

  BOT.command :set_parchment_url do |event, *args|
    break unless event.user.id.host?

    url = args.first.to_s
    if url.empty?
      event.respond('Use `!set_parchment_url URL`.')
      break
    end

    Setting.parchment_url = url
    event.respond('Parchment URL has been updated.')
  end

  BOT.command :set_spectator_channel do |event, *args|
    break unless event.user.id.host?

    settings = {
      'draft' => :spectator_draft_channel_id,
      'elimination' => :spectator_elimination_channel_id,
      'bootlist' => :spectator_bootlist_channel_id
    }

    game = args.shift.to_s.downcase
    setting_name = settings[game]
    unless setting_name
      event.respond('Use `!set_spectator_channel draft|elimination|bootlist [channel_id]`. Leave channel_id blank to use this channel.')
      break
    end

    channel_id = args.join.to_i
    channel_id = event.channel.id if channel_id.zero?
    Setting.public_send("#{setting_name}=", channel_id)

    channel = channel_from_setting(setting_name)
    unless channel
      event.respond("Saved `Setting.#{setting_name}` as `#{channel_id}`, but I can't access that channel.")
      break
    end

    event.respond("#{channel.mention} has been set as the **#{game.capitalize} Game** channel.")
  end
end
