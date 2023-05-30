class Season < ActiveRecord::Base
  has_many :items, foreign_key: 'season_id'
end