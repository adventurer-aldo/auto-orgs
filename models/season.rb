class Season < ActiveRecord::Base
  has_many :items, foreign_key: 'season_id'
  has_many :players, foreign_key: 'season_id'
  has_many :councils, foreign_key: 'season_id'
  has_many :alliances, foreign_key: 'season_id'
  has_many :tribes, foreign_key: 'season_id'
  has_many :votes, through: :councils
end