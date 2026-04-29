class Episode < ActiveRecord::Base
  belongs_to :season, foreign_key: 'season_id'
end
