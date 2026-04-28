class Sunny
  def self.host_ids_from_event(event, args)
    ids = event.message.mentions.map(&:id)
    ids += args.map(&:to_i).select(&:positive?)
    ids.uniq
  end

  def self.host_name_matches(query)
    query = query.to_s.downcase
    return [] if query == ''

    Setting.hosts_ids.select do |id|
      user = BOT.user(id)
      names = [user&.username, user&.display_name, user&.name].compact.map(&:downcase)
      names.any? { |name| name.include?(query) }
    end
  end

  def self.host_display_name(id)
    user = BOT.user(id)
    user ? user.display_name : "Missing user #{id}"
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
    if ids.empty?
      matches = host_name_matches(args.join(' '))
      return event.respond('Mention a host, provide a user ID, or write part of their username/display name.') if args.empty?
      return event.respond('No host matched that name.') if matches.empty?
      return event.respond("More than one host matched that name: #{matches.map { |id| host_display_name(id) }.join(', ')}") if matches.size > 1

      ids = matches
    end

    Setting.hosts_ids = Setting.hosts_ids - ids
    event.respond("Host list updated. Removed: #{ids.map { |id| host_display_name(id) }.join(', ')}")
  end
end
