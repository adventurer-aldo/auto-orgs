class Sunny

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
            embed.color = event.server.role(TRIBAL_PING).color
          end
          item.update(player_id: player.id)
        end
        return

      end
    end

  end
end