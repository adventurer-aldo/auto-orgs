module Alliances
  class Association < ActiveRecord::Base
    belongs_to :alliance, class_name: 'Alliances::Group', foreign_key: 'alliance_id'
    belongs_to :player, class_name: 'Player', foreign_key: 'player_id'
  end
end