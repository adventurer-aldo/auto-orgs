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

  PARCHMENT_COLORS = %w[red black green blue yellow pink purple cyan violet white]

  def self.deny_every_spectate
    Discordrb::Overwrite.new(Setting.everyone_role_id, deny: 3072)
  end

  def self.every_spectate
    Discordrb::Overwrite.new(Setting.everyone_role_id, allow: 1088, deny: 2048)
  end

  def self.true_spectate
    Discordrb::Overwrite.new(Setting.trusted_spectator_role_id, type: 'role', allow: 1088, deny: 2048)
  end

  def self.jury_spectate
    Discordrb::Overwrite.new(Setting.jury_role_id, type: 'role', allow: 1088, deny: 2048)
  end

  def self.prejury_spectate
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
