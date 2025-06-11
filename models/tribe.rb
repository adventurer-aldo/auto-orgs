class Tribe < ActiveRecord::Base
  has_many :players, foreign_key: 'tribe_id'
  has_many :councils, foreign_key: 'tribe_id'
  has_many :votes, through: :councils
  belongs_to :season, foreign_key: 'season_id'
  
  has_many :challenges, foreign_key: 'tribe_id'
  # Battleships
  has_many :damages, foreign_key: 'tribe_id'
  has_many :battleships, foreign_key: 'tribe_id'
end
