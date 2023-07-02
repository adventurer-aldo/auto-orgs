class Vote < ActiveRecord::Base
  belongs_to :council, foreign_key: 'council_id'
  belongs_to :player, foreign_key: 'player_id'
end