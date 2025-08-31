class Tribe < ActiveRecord::Base
  has_many :players, foreign_key: 'tribe_id'
  has_many :councils, foreign_key: 'tribe_id'
  has_many :votes, through: :councils
  belongs_to :season, foreign_key: 'season_id'
  
  has_many :challenges, class_name: 'Challenges::Tribal', foreign_key: 'tribe_id'
  # Battleships
  has_many :damages, class_name: 'Challenges::Battleships::Damage', foreign_key: 'tribe_id'
  has_many :participants, foreign_key: 'tribe_id'
  has_many :battleships, class_name: 'Challenges::Battleships::Ship', foreign_key: 'tribe_id'
end
