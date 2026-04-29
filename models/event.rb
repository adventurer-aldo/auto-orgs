class Event < ActiveRecord::Base
  belongs_to :player, foreign_key: 'player_id', optional: true
  belongs_to :item, foreign_key: 'item_id', optional: true
  belongs_to :episode, foreign_key: 'episode_id', optional: true
end
