class Sunny

  BOT.command :clean, description: 'Delete all Data except Settings.' do |event|
    break unless HOSTS.include? event.user.id

    Vote.destroy_all
    Council.destroy_all
    Item.destroy_all
    Alliance.destroy_all
    Player.destroy_all
    Tribe.destroy_all
    return 'All Data has been destroyed successfuly!'
  end

  BOT.command :prune, description: 'Cleans up a channel.' do |event|
    break unless HOSTS.include? event.user.id

    event.channel.prune(100)
    return
  end

  def self.make_item_commands
    @items = Item.where(season_id: Setting.last.season)
    return if @items.empty?

    @items.each do |item|
      BOT.command item.code.to_sym do |event|
        break unless event.user.id.player?

        player = Player.find_by(user_id: event.user.id, season_id: Setting.last.season)
        break unless %w[In Immune Idoled Exiled].include? player.status

        event.channel.start_typing
        sleep(2)
        event.respond('**You found an item!**')

        if item.owner.nil?
          subm = BOT.channel(player.submissions)
          subm.start_typing
          sleep(4)
          subm.send_embed do |embed|
            embed.title = item.name
            embed.description = "**Description:** #{item.description}\n"
            embed.description << "\n**Code:** `#{item.code}`"
            embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "You can play it with `!play #{item.code}` or give it to someone else with `!give #{item.code}`")
            embed.color = event.server.role(TRIBAL_PING).color
          end
          item.update(owner: player.id)
        else
          event.channel.start_typing
          sleep(2)
          event.respond('But it was already found by someone else already...')
        end
        return

      end
    end

  end

  BOT.command :update, description: 'Updates the item list so that new codes can be found.' do |event|
    break unless HOSTS.include? event.user.id

    make_item_commands
    event.respond('The items list has been updated!')
  end

  make_item_commands
end
