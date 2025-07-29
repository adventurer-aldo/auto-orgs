module Challenges
  class Individual < ActiveRecord::Base
    belongs_to :player, foreign_key: 'player_id'
  end
end