class Sunny

  def self.register_item_command(item)
    item_code = item.code
    BOT.remove_command(item_code.to_sym)
    item_command_codes.delete(item_code)
    item_command_codes << item_code

    BOT.command item_code.to_sym do |event|
      break unless event.user.id.player?

      item = Item.find_by(code: item_code, season_id: Setting.season_id)
      break unless item

      player = Player.find_by(user_id: event.user.id, season_id: Setting.season_id)
      break unless player && %w[In Immune Idoled Exiled].include?(player.status)

      event.channel.start_typing
      sleep(2)
      event.respond('**You found an item!**')

      if !item.player_id.nil?
        event.channel.start_typing
        sleep(2)
        event.respond('But it was already found by someone else already...')
      elsif item.own_restriction != 0 && item.own_restriction != player.tribe_id
        event.channel.start_typing
        sleep(2)
        event.respond("But you are not able to obtain it...")
      else
        subm = BOT.channel(player.submissions)
        subm.start_typing
        sleep(4)
        subm.send_embed do |embed|
          embed.title = item.name
          embed.description = "**Description:** #{item.description}\n"
          embed.description << "\n**Code:** `#{item.code}`"
          embed.footer = Discordrb::Webhooks::EmbedFooter.new(text: "You can play it with `!play #{item.code}` or give it to someone else with `!give #{item.code}`")
          embed.color = event.server.role(Setting.tribal_ping_role_id).color
        end
        item.update(player_id: player.id)
        record_and_send_event('item_found', player: player, item: item.reload)
      end
      return
    end
  end

  def self.make_item_commands
    item_command_codes.each { |code| BOT.remove_command(code.to_sym) }
    item_command_codes.clear

    @items = Item.where(season_id: Setting.season_id)
    return if @items.empty?

    @items.each do |item|
      register_item_command(item)
    end

  end
end
