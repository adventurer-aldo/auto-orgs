module Challenges
  class Details < ActiveRecord::Base
    has_many :individuals, class_name: 'Challenges::Individual', foreign_key: 'player_id'
    has_many :tribals, class_name: 'Challenges::Tribal', foreign_key: 'player_id'
  end
end