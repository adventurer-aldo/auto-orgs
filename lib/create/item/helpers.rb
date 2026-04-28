require 'securerandom'
require 'shellwords'

class Sunny
  @pending_items = {}

  def self.pending_items
    @pending_items ||= {}
  end

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
    pending_items[token] = {
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

  def self.item_argument_value(token, prefix)
    token = token.delete_prefix('[').delete_suffix(']')
    return unless token.start_with?(prefix)

    token.delete_prefix(prefix)
  end

  def self.parse_item_arguments(raw, role_mentions)
    tokens = Shellwords.split(raw)
    return nil if tokens.size < 3

    name = tokens.shift
    description = tokens.shift
    code = tokens.filter_map { |token| item_argument_value(token, 'code:') }.first&.gsub(' ', '_')
    mentioned_role_ids = role_mentions.map(&:id)
    tribe_from_mention = item_tribes.find { |tribe| mentioned_role_ids.include?(tribe.role_id) }
    tribe_from_token = tokens.filter_map do |token|
      tribe_id = item_argument_value(token, 'tribe:')
      next tribe_id.to_i if tribe_id
      next token.to_i if token.match?(/\A\d+\z/)
    end.find { |id| item_tribes.exists?(id: id) }
    own_restriction = tribe_from_mention&.id || tribe_from_token || 0
    functions = tokens.reject do |token|
      item_argument_value(token, 'code:') ||
        item_argument_value(token, 'tribe:') ||
        token.start_with?('<@&') ||
        token.match?(/\A\d+\z/)
    end.map(&:downcase)

    { name: name, description: description, functions: functions, own_restriction: own_restriction, code: code }
  rescue ArgumentError
    :invalid_quotes
  end

  def self.create_pending_item(token)
    payload = pending_items[token]
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
end
