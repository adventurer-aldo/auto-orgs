module Challenges
  class Participant < ActiveRecord::Base
    belongs_to :player, foreign_key: 'player_id'
    belongs_to :tribe, foreign_key: 'tribe_id'
  end
end
