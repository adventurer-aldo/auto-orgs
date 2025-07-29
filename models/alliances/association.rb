module Alliances
  class Association < ActiveRecord::Base
    belongs_to :alliance, class_name: 'Alliances::Group', foreign_key: 'player_id'
  end
end