require_relative 'item/helpers'
require_relative 'item/interactions'

class Sunny
  # > Item
  # > Council

  BOT.command :items do |event, *args|
    season_id = args[0]&.to_i || Setting.season_id
    items = Item.where(season_id: season_id).order(:name)

    return event.respond("No items found for Season #{season_id}.") if items.empty?

    event.channel.send_embed do |embed|
      embed.title = "Season #{season_id} Items"
      embed.description = items.map do |item|
        item_codes = item.functions.map { |function| item_code_name(function) }.join(', ')
        "**#{item.name}**\nType: #{item_codes}\n#{item.description}"
      end.join("\n\n")
    end
  end

  BOT.command :item, description: "Creates a new item to be claimed." do |event, *args|
    break unless event.user.id.host?

    raw = event.message.content.split(/\s+/, 2)[1].to_s
    if raw.empty?
      event.channel.send_message('Create an item with the button below.', false, nil, nil, nil, nil, item_create_button_view)
      break
    end

    parsed = parse_item_arguments(raw, event.message.role_mentions)

    if parsed == :invalid_quotes
      event.respond('I could not parse that. Make sure quoted names and descriptions are closed.')
      break
    end

    unless parsed && valid_item_functions?(parsed[:functions])
      event.respond("Use `!item \"Name\" \"Description\" function_code @TribeRole code:item_code`.\nThe role and code are optional. Valid function codes: `#{DEFINED_FUNCTIONS.join('`, `')}`")
      break
    end

    pending_code = parsed[:code].to_s.empty? ? item_code_from_name(parsed[:name]) : parsed[:code]
    code_taken = Item.where(code: pending_code, season_id: Setting.season_id).exists?
    if code_taken
      event.respond('An item with this code already exists!')
      break
    end

    token = prepare_pending_item(user_id: event.user.id, channel_id: event.channel.id, **parsed)
    event.channel.send_message(item_summary(pending_items[token]), false, nil, nil, nil, nil, item_confirmation_view(token))
  end
end
