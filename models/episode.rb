class Episode < ActiveRecord::Base
  belongs_to :season, foreign_key: 'season_id'
  has_many :events, foreign_key: 'episode_id'
end
