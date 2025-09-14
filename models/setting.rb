class Setting < ActiveRecord::Base
  def self.game_stage
    return find_by(name: 'game_stage').values.first.to_i
  end

  def self.game_stage=(value)
    find_by(name: 'game_stage').update(values: [value])
  end

  def self.season_id
    return find_by(name: 'season_id').values.first.to_i
  end

  def self.season
    return season_id
  end

  def self.season_id=(value)
    find_by(name: 'season_id').update(values: [value])
  end

  def self.archive_category
    return find_by(name: 'archive_category').values.first.to_i
  end

  def self.archive_category=(value)
    find_by(name: 'archive_category').update(values: [value])
  end

  def self.tribes
    return find_by(name: 'tribes').values.map(&:to_i)
  end

  def self.tribes=(value)
    find_by(name: 'tribes').update(values:)
  end

end