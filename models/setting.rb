class Setting < ActiveRecord::Base
  def self.game_stage
    return find_by(name: 'game_stage').value.first.to_i
  end

  def self.season_id
    return find_by(name: 'season_id').value.first.to_i
  end

  def self.season
    return season_id
  end

  def self.archive_category
    return find_by(name: 'archive_category').value.first.to_i
  end

  def self.tribes
    return find_by(name: 'tribes').value.map(&:to_i)
  end


end