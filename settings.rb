# frozen_string_literal: true

class Sunny
  # PLAYER STATUS
  ALIVE = %w[In Immune Idoled]
  DEAD = %w[Out Jury]

  # TRIBAL
  COUNTING = %W(First Second Third Fourth Fifth Sixth Seventh Eigthth Ninth Tenth 
  Eleventh Twelfth Thirteenth Fourteenth Fifteenth Sixteenth Seventeeth Eighteenth Nineteenth Twentieth 
  Twenty-First Twenty-Second Twenty-Third Twenty-Fourth)


  DEFINED_FUNCTIONS = %w[
      idol
      steal_vote
      block_vote
      extra_vote
      safety_without_power
  ]

  FONTS = Dir.glob(File.join(__dir__, "fonts", "*")).select { |f| File.file?(f) }

  def self.debug_mode?
    @debug_mode == true
  end

  def self.debug_mode=(value)
    @debug_mode = value == true
  end

  def self.deny_every_spectate
    Discordrb::Overwrite.new(Setting.everyone_role_id, deny: 3072)
  end

  def self.debug_spectator_denies
    [
      Setting.spectator_role_id,
      Setting.trusted_spectator_role_id,
      Setting.jury_role_id,
      Setting.prejury_role_id
    ].uniq.filter_map do |role_id|
      Discordrb::Overwrite.new(role_id, type: 'role', deny: 3072) if role_id.to_i.positive?
    end
  end

  def self.private_spectate_overwrites
    [deny_every_spectate] + (debug_mode? ? debug_spectator_denies : [])
  end

  def self.public_spectate_overwrites
    debug_mode? ? private_spectate_overwrites : [every_spectate]
  end

  def self.every_spectate
    return deny_every_spectate if debug_mode?

    Discordrb::Overwrite.new(Setting.everyone_role_id, allow: 1088, deny: 2048)
  end

  def self.true_spectate
    return Discordrb::Overwrite.new(Setting.trusted_spectator_role_id, type: 'role', deny: 3072) if debug_mode?

    Discordrb::Overwrite.new(Setting.trusted_spectator_role_id, type: 'role', allow: 1088, deny: 2048)
  end

  def self.jury_spectate
    return Discordrb::Overwrite.new(Setting.jury_role_id, type: 'role', deny: 3072) if debug_mode?

    Discordrb::Overwrite.new(Setting.jury_role_id, type: 'role', allow: 1088, deny: 2048)
  end

  def self.prejury_spectate
    return Discordrb::Overwrite.new(Setting.prejury_role_id, type: 'role', deny: 3072) if debug_mode?

    Discordrb::Overwrite.new(Setting.prejury_role_id, type: 'role', allow: 1088, deny: 2048)
  end

  def self.active_councils
    Council.where(season_id: Setting.season_id).where.not(stage: 5)
  end

  def self.active_council_tribe_ids
    active_councils.flat_map(&:tribes).uniq
  end

  def self.season_title
    season = Setting.season
    name = season.respond_to?(:name) && season.name.to_s != '' ? ": #{season.name}" : ''
    "Alvivor S#{Setting.season_id}#{name}"
  end

end
