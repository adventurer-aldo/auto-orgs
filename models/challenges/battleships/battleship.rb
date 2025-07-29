module Challenges
  module Battleships
    class Ship < ActiveRecord::Base
      belongs_to :tribe, foreign_key: 'tribe_id'
    end
  end
end
