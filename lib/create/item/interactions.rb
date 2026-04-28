require_relative 'helpers'

class Sunny
  BOT.button(custom_id: 'item_modal_start') do |event|
    if !event.user.id.host?
      event.respond(content: 'Only hosts can create items.', ephemeral: true)
      break
    end

    event.show_modal(title: 'Create a new Item', custom_id: "item_modal:#{event.channel.id}") do |modal|
      modal.label(label: 'Name') do |row|
        row.text_input(custom_id: 'item_name', style: :short, min_length: 1, max_length: 100, required: true)
      end
      modal.label(label: 'Description') do |row|
        row.text_input(custom_id: 'item_description', style: :paragraph, min_length: 1, max_length: 1000, required: true)
      end
      modal.label(label: 'Functions') do |row|
        row.string_select(
          custom_id: 'item_functions',
          options: item_function_options,
          placeholder: 'Choose one or more functions',
          min_values: 1,
          max_values: DEFINED_FUNCTIONS.size,
          required: true
        )
      end
      modal.label(label: 'Code') do |row|
        row.text_input(custom_id: 'item_code', style: :short, max_length: 100, required: false, placeholder: 'Leave blank to use the name')
      end
    end
  end

  BOT.modal_submit(custom_id: /\Aitem_modal:/) do |event|
    if !event.user.id.host?
      event.respond(content: 'Only hosts can create items.', ephemeral: true)
      break
    end

    functions = event.values('item_functions') || []
    unless valid_item_functions?(functions)
      event.respond(content: "One or more function codes does not exist.\nValid function codes: `#{DEFINED_FUNCTIONS.join('`, `')}`", ephemeral: true)
      break
    end

    code = event.value('item_code').to_s.strip.gsub(' ', '_')
    code = item_code_from_name(event.value('item_name')) if code.empty?
    if Item.where(code: code, season_id: Setting.season_id).exists?
      event.respond(content: 'An item with this code already exists!', ephemeral: true)
      break
    end

    channel_id = event.custom_id.split(':', 2).last.to_i
    token = prepare_pending_item(
      user_id: event.user.id,
      channel_id: channel_id,
      name: event.value('item_name'),
      description: event.value('item_description'),
      functions: functions,
      code: code
    )

    event.respond(content: 'Choose who can claim this item.', ephemeral: true, components: item_tribe_select_view(token))
  end

  BOT.string_select(custom_id: /\Aitem_restriction:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_items[token]

    if payload.nil? || payload[:user_id] != event.user.id
      event.respond(content: 'This item draft is no longer available.', ephemeral: true)
      break
    end

    payload[:own_restriction] = event.values.first.to_i
    event.update_message(content: item_summary(payload), components: item_confirmation_view(token))
  end

  BOT.button(custom_id: /\Aitem_cancel:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_items[token]

    if payload.nil? || payload[:user_id] != event.user.id
      event.respond(content: 'This item draft is no longer available.', ephemeral: true)
      break
    end

    pending_items.delete(token)
    event.update_message(content: 'Item creation cancelled.', components: nil)
  end

  BOT.button(custom_id: /\Aitem_confirm:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_items[token]

    if payload.nil? || payload[:user_id] != event.user.id
      event.respond(content: 'This item draft is no longer available.', ephemeral: true)
      break
    end

    if Item.where(code: payload[:code], season_id: Setting.season_id).exists?
      pending_items.delete(token)
      event.update_message(content: 'An item with this code already exists!', components: nil)
      break
    end

    item = create_pending_item(token)
    pending_items.delete(token)
    register_item_command(item)
    event.update_message(content: '**Your item has been created!**', components: nil)

    BOT.channel(payload[:channel_id]).send_embed('**New item has been created!**') do |embed|
      embed.title = item.name
      embed.description = "**Code:** `#{item.code}`\n"
      embed.description << "**Description:** #{item.description}\n"
      embed.description << "**Restricted To:** #{item_restriction_name(item.own_restriction)}"
    end
  end

  BOT.string_select(custom_id: /\Aitem_remove_select:/) do |event|
    user_id = event.custom_id.split(':', 2).last.to_i
    if user_id != event.user.id
      event.respond(content: 'Only the host who opened this menu can use it.', ephemeral: true)
      break
    end

    item = Item.find_by(id: event.values.first.to_i, season_id: Setting.season_id)
    unless item
      event.update_message(content: 'That item no longer exists.', components: nil)
      break
    end

    token = prepare_pending_item_removal(user_id: event.user.id, item_id: item.id)
    event.update_message(content: item_removal_summary(item), components: item_removal_confirmation_view(token))
  end

  BOT.button(custom_id: /\Aitem_remove_cancel:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_item_removals[token]

    if payload.nil? || payload[:user_id] != event.user.id
      event.respond(content: 'This item deletion is no longer available.', ephemeral: true)
      break
    end

    pending_item_removals.delete(token)
    event.update_message(content: 'Item deletion cancelled.', components: nil)
  end

  BOT.button(custom_id: /\Aitem_remove_confirm:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = pending_item_removals[token]

    if payload.nil? || payload[:user_id] != event.user.id
      event.respond(content: 'This item deletion is no longer available.', ephemeral: true)
      break
    end

    item = Item.find_by(id: payload[:item_id], season_id: Setting.season_id)
    pending_item_removals.delete(token)

    unless item
      event.update_message(content: 'That item no longer exists.', components: nil)
      break
    end

    name = item.name
    code = item.code
    item.destroy
    BOT.remove_command(code.to_sym)
    item_command_codes.delete(code)
    event.update_message(content: "**Deleted item:** #{name} (`#{code}`)", components: nil)
  end
end
