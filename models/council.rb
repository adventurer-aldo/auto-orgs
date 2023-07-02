class Council < ActiveRecord::Base
  has_many :votes, foreign_key: 'council_id', dependent: :destroy
  has_many :players, through: :votes
  belongs_to :tribe, foreign_key: 'tribe_id'
end
