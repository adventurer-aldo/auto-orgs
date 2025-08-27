module Challenges
  module Wordle
    class Word < ActiveRecord::Base
      belongs_to :tribe, foreign_key: 'tribe_id'
    end
  end
end
