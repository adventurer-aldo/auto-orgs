class Sunny
  def self.archive_category_for(event)
    archive_category = BOT.channel(Setting.archive_category_id)
    return archive_category if archive_category && archive_category.children.size < 50

    index = 2
    archive_name = "Archive #{index}"
    while event.server.channels.any? { |channel| channel.name == archive_name }
      index += 1
      archive_name = "Archive #{index}"
    end

    archive_category = event.server.create_channel(archive_name, 4)
    Setting.archive_category_id = archive_category.id
    archive_category
  end

  def self.archive_channel(channel, event)
    channel.parent = archive_category_for(event)
    channel.permission_overwrites.each do |role, _perms|
      if event.server.role(role)
        if role != Setting.everyone_role_id
          channel.define_overwrite(event.server.role(role), 1024, 2048)
        else
          channel.define_overwrite(event.server.role(role), 0, 3072)
        end
      elsif event.server.member(role)
        channel.define_overwrite(event.server.member(role), 1024, 2048)
      end
    end
  end

  BOT.command :archive, description: "Sends the current channel to archive and removes talking permissions, while allowing it to be viewed. Add 'all' to archive all channels within the current category." do |event, *args|
    break unless event.user.id.host?

    if args.join(' ') != 'all'
      event.respond("**You can't archive this channel!**") if [Setting.jury_splitter_channel_id, Setting.prejury_splitter_channel_id].include? event.channel.id
      break if [Setting.jury_splitter_channel_id, Setting.prejury_splitter_channel_id, Setting.playing_splitter_channel_id].include? event.channel.id

      archive_channel(event.channel, event)
      event.respond ':ballot_box_with_check: **This channel has been archived!**'
    else
      event.channel.parent.children.each do |channel|
        next channel if [Setting.jury_splitter_channel_id, Setting.prejury_splitter_channel_id, Setting.playing_splitter_channel_id].include? channel.id

        archive_channel(channel, event)
        BOT.send_message(channel.id, ':ballot_box_with_check: **This channel has been archived!**')
      end
    end
    return
  end
end
