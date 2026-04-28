class Sunny
  def self.host_ids_from_event(event, args)
    ids = event.message.mentions.map(&:id)
    ids += args.map(&:to_i).select(&:positive?)
    ids.uniq
  end

  BOT.command :add_host do |event, *args|
    break unless event.user.id.host?

    ids = host_ids_from_event(event, args)
    return event.respond('Mention at least one user or provide at least one user ID.') if ids.empty?

    Setting.hosts_ids = (Setting.hosts_ids + ids).uniq
    event.respond("Host list updated: #{ids.map { |id| "<@#{id}>" }.join(', ')}")
  end

  BOT.command :remove_host do |event, *args|
    break unless event.user.id.host?

    ids = host_ids_from_event(event, args)
    return event.respond('Mention at least one user or provide at least one user ID.') if ids.empty?

    Setting.hosts_ids = Setting.hosts_ids - ids
    event.respond("Host list updated. Removed: #{ids.map { |id| "<@#{id}>" }.join(', ')}")
  end
end
