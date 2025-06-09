class Buddy < ActiveRecord::Base
  belongs_to :player, foreign_key: 'player_id'
end
