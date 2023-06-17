class Tribe < ActiveRecord::Base
  has_many :players, foreign_key: 'tribe_id'
  has_many :councils, foreign_key: 'tribe_id'
  has_many :votes, through: :councils
end
