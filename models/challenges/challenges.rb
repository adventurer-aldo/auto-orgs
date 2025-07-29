module Challenges
  class Tribal < ActiveRecord::Base
    belongs_to :tribe, foreign_key: 'tribe_id'
  end
end