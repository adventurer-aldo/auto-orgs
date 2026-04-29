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
end
