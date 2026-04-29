class Setting < ActiveRecord::Base
  INTEGER_SETTINGS = %w[
    server_id
    alliances_category_id
    councils_category_id
    ftc_category_id
    challenges_category_id
    tribes_category_id
    confessionals_category_id
    applications_category_id
    modlog_channel_id
    user_join_channel_id
    user_leave_channel_id
    jury_channel_id
    immunity_role_id
    everyone_role_id
    castaway_role_id
    jury_role_id
    prejury_role_id
    spectator_role_id
    trusted_spectator_role_id
    tribal_ping_role_id
    challenges_ping_role_id
    announcements_ping_role_id
    playing_splitter_channel_id
    prejury_splitter_channel_id
    jury_splitter_channel_id
    host_chat_channel_id
    archive_category_id
  ].freeze

  ARRAY_SETTINGS = %w[
    hosts_ids
    tribes
  ].freeze

  STRING_SETTINGS = %w[
    parchment_url
  ].freeze

  def self.setting_row(name)
    find_or_create_by(name:) do |setting|
      setting.values = []
    end
  end

  def self.integer_setting(name)
    Array(setting_row(name).values).first.to_i
  end

  def self.set_integer_setting(name, value)
    setting_row(name).update(values: [value])
  end

  def self.array_setting(name)
    Array(setting_row(name).values).map(&:to_i)
  end

  def self.set_array_setting(name, value)
    setting_row(name).update(values: Array(value))
  end

  def self.string_setting(name)
    Array(setting_row(name).values).first.to_s
  end

  def self.set_string_setting(name, value)
    setting_row(name).update(values: [value.to_s])
  end

  INTEGER_SETTINGS.each do |setting_name|
    define_singleton_method(setting_name) do
      integer_setting(setting_name)
    end

    define_singleton_method("#{setting_name}=") do |value|
      set_integer_setting(setting_name, value)
    end
  end

  ARRAY_SETTINGS.each do |setting_name|
    define_singleton_method(setting_name) do
      array_setting(setting_name)
    end

    define_singleton_method("#{setting_name}=") do |value|
      set_array_setting(setting_name, value)
    end
  end

  STRING_SETTINGS.each do |setting_name|
    define_singleton_method(setting_name) do
      string_setting(setting_name)
    end

    define_singleton_method("#{setting_name}=") do |value|
      set_string_setting(setting_name, value)
    end
  end

  def self.hosts
    hosts_ids.filter_map { |id| Sunny::BOT.user(id) }
  end

  def self.confirmation?(text)
    normalized = text.to_s.downcase.gsub(/[.!?]/, '').strip
    %w[yes yea yeah yeh yuh yup y ye heck\ yeah yep yessir indeed yessey yess].include?(normalized)
  end

  def self.game_stage
    return integer_setting('game_stage')
  end

  def self.game_stage=(value)
    set_integer_setting('game_stage', value)
  end

  def self.season_id
    return integer_setting('season_id')
  end

  def self.season
    return Season.find_by(id: season_id)
  end

  def self.season_id=(value)
    set_integer_setting('season_id', value)
  end

  def self.archive_category
    archive_category_id
  end

  def self.archive_category=(value)
    self.archive_category_id = value
  end

end
