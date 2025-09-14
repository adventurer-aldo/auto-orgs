module SpectatorGame
  class Draft < ActiveRecord::Base
    def score
      winner_pick_score = Player.find_by(id: winner_pick, season_id: Setting.season)&.rank || 0
      pick_1_score = Player.find_by(id: pick_1, season_id: Setting.season)&.rank || 0
      pick_2_score = Player.find_by(id: pick_2, season_id: Setting.season)&.rank || 0
      pick_3_score = Player.find_by(id: pick_3, season_id: Setting.season)&.rank || 0

      return (winner_pick_score * 2) + pick_1_score + pick_2_score + pick_3_score
    end
  end
end