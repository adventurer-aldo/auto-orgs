module SpectatorGame
  class Bootlist < ActiveRecord::Base
    UserScore = Struct.new(:user_id, :score)

    belongs_to :player, foreign_key: 'player_id'

    def score
      return 0 unless player&.rank

      (player.rank.to_i - rank.to_i).abs
    end

    def self.entries_for_user(user_id, season_id = Setting.season_id)
      where(user_id: user_id, season_id: season_id).order(:rank)
    end

    def self.user_scores(season_id = Setting.season_id)
      where(season_id: season_id).includes(:player).group_by(&:user_id).map do |user_id, picks|
        UserScore.new(user_id, picks.sum(&:score))
      end
    end
  end
end
