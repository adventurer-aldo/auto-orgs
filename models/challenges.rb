class Challenge < ActiveRecord::Base
  belongs_to :tribe, foreign_key: 'tribe_id'
end