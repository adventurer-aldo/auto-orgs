class Setting < ActiveRecord::Base
  def self.game_stage
    return all.last.game_stage
  end

  def self.season_id
    return all.last.season
  end
  
  def self.season
    return season_id
  end

end