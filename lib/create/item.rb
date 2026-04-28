class Sunny
  # > Item
  # > Council
  require 'securerandom'
  require 'shellwords'

  @pending_items = {}

  def self.item_code_name(code)
    code.to_s.split('_').map(&:capitalize).join(' ')
  end

  def self.item_tribes
    Tribe.where(season_id: Setting.season_id).order(:id)
  end

  def self.item_restriction_name(own_restriction)
    return 'No one' if own_restriction.to_i.zero?

    tribe = Tribe.find_by(id: own_restriction)
    tribe ? "#{tribe.name} tribe" : "Unknown tribe (#{own_restriction})"
  end

  def self.item_code_from_name(name)
    name.downcase.gsub(/[^a-z0-9]+/, '_').gsub(/\A_+|_+\z/, '')
  end

  def self.item_summary(payload)
    <<~TEXT
      **Create this item?**
      **Name:** #{payload[:name]}
      **Description:** #{payload[:description]}
      **Functions:** #{payload[:functions].map { |function| item_code_name(function) }.join(', ')}
      **Code:** `#{payload[:code]}`
      **Restricted To:** #{item_restriction_name(payload[:own_restriction])}
    TEXT
  end

  def self.item_confirmation_view(token)
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.button(custom_id: "item_confirm:#{token}", label: 'Create', style: :success)
      row.button(custom_id: "item_cancel:#{token}", label: 'Cancel', style: :danger)
    end
    view
  end

  def self.item_tribe_options
    [{ label: 'No restriction', value: '0' }] + item_tribes.map do |tribe|
      role = BOT.server(Setting.server_id)&.role(tribe.role_id)
      { label: role&.name || tribe.name, value: tribe.id.to_s, description: "Tribe ID #{tribe.id}" }
    end
  end

  def self.item_tribe_select_view(token)
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.string_select(
        custom_id: "item_restriction:#{token}",
        options: item_tribe_options.first(25),
        placeholder: 'Choose a tribe restriction',
        min_values: 1,
        max_values: 1
      )
    end
    view
  end

  def self.item_function_options
    DEFINED_FUNCTIONS.map do |function|
      { label: item_code_name(function), value: function }
    end
  end

  def self.item_create_button_view
    view = Discordrb::Webhooks::View.new
    view.row do |row|
      row.button(custom_id: 'item_modal_start', label: 'Create Item', style: :primary)
    end
    view
  end

  def self.prepare_pending_item(user_id:, channel_id:, name:, description:, functions:, own_restriction: 0, code: nil)
    code = item_code_from_name(name) if code.nil? || code.empty?
    token = SecureRandom.hex(8)
    @pending_items[token] = {
      user_id: user_id,
      channel_id: channel_id,
      name: name,
      description: description,
      functions: functions,
      own_restriction: own_restriction,
      code: code
    }
    token
  end

  def self.valid_item_functions?(functions)
    functions.any? && functions.all? { |function| DEFINED_FUNCTIONS.include?(function) }
  end

  def self.parse_item_arguments(raw, role_mentions)
    tokens = Shellwords.split(raw)
    return nil if tokens.size < 3

    name = tokens.shift
    description = tokens.shift
    code_token = tokens.find { |token| token.start_with?('code:') }
    code = code_token&.delete_prefix('code:')&.gsub(' ', '_')
    mentioned_role_ids = role_mentions.map(&:id)
    tribe_from_mention = item_tribes.find { |tribe| mentioned_role_ids.include?(tribe.role_id) }
    tribe_from_token = tokens.filter_map do |token|
      next token.delete_prefix('tribe:').to_i if token.start_with?('tribe:')
      next token.to_i if token.match?(/\A\d+\z/)
    end.find { |id| item_tribes.exists?(id: id) }
    own_restriction = tribe_from_mention&.id || tribe_from_token || 0
    functions = tokens.reject do |token|
      token.start_with?('code:') || token.start_with?('<@&') || token.start_with?('tribe:') || token.match?(/\A\d+\z/)
    end.map(&:downcase)

    { name: name, description: description, functions: functions, own_restriction: own_restriction, code: code }
  rescue ArgumentError
    :invalid_quotes
  end

  def self.create_pending_item(token)
    payload = @pending_items[token]
    return nil unless payload

    Item.create(
      code: payload[:code],
      name: payload[:name],
      description: payload[:description],
      functions: payload[:functions],
      own_restriction: payload[:own_restriction],
      season_id: Setting.season_id
    )
  end

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
      event.respond("Use `!item \"Name\" \"Description\" function_code @TribeRole [code:item_code]`.\nValid function codes: `#{DEFINED_FUNCTIONS.join('`, `')}`")
      break
    end

    pending_code = parsed[:code].to_s.empty? ? item_code_from_name(parsed[:name]) : parsed[:code]
    code_taken = Item.where(code: pending_code, season_id: Setting.season_id).exists?
    if code_taken
      event.respond('An item with this code already exists!')
      break
    end

    token = prepare_pending_item(user_id: event.user.id, channel_id: event.channel.id, **parsed)
    event.channel.send_message(item_summary(@pending_items[token]), false, nil, nil, nil, nil, item_confirmation_view(token))
  end

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
    payload = @pending_items[token]

    if payload.nil? || payload[:user_id] != event.user.id
      event.respond(content: 'This item draft is no longer available.', ephemeral: true)
      break
    end

    payload[:own_restriction] = event.values.first.to_i
    event.update_message(content: item_summary(payload), components: item_confirmation_view(token))
  end

  BOT.button(custom_id: /\Aitem_cancel:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = @pending_items[token]

    if payload.nil? || payload[:user_id] != event.user.id
      event.respond(content: 'This item draft is no longer available.', ephemeral: true)
      break
    end

    @pending_items.delete(token)
    event.update_message(content: 'Item creation cancelled.', components: nil)
  end

  BOT.button(custom_id: /\Aitem_confirm:/) do |event|
    token = event.custom_id.split(':', 2).last
    payload = @pending_items[token]

    if payload.nil? || payload[:user_id] != event.user.id
      event.respond(content: 'This item draft is no longer available.', ephemeral: true)
      break
    end

    if Item.where(code: payload[:code], season_id: Setting.season_id).exists?
      @pending_items.delete(token)
      event.update_message(content: 'An item with this code already exists!', components: nil)
      break
    end

    item = create_pending_item(token)
    @pending_items.delete(token)
    make_item_commands
    event.update_message(content: '**Your item has been created!**', components: nil)

    BOT.channel(payload[:channel_id]).send_embed do |embed|
      embed.title = item.name
      embed.description = "**Code:** `#{item.code}`\n"
      embed.description << "**Description:** #{item.description}\n"
      embed.description << "**Restricted To:** #{item_restriction_name(item.own_restriction)}"
    end
  end
end
