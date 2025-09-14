class Setting < ActiveRecord::Base
  def self.game_stage
    return all.last.game_stage
  end
end