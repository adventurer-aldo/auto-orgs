class Item < ActiveRecord::Base
  belongs_to :season, foreign_key: 'season_id'
  belongs_to :player, foreign_key: 'owner_id'
end
