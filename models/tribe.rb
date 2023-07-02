class Tribe < ActiveRecord::Base
  has_many :players, foreign_key: 'tribe_id'
  has_many :councils, foreign_key: 'tribe_id'
  has_many :votes, through: :councils
  belongs_to :season, foreign_key: 'season_id'
end
