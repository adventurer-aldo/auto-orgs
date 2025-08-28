module Alliances
  class Group < ActiveRecord::Base
    has_many :alliance_associatons, foreign_key: 'alliance_id', class_name: 'Alliances::Association', dependent: :destroy
    has_many :players, through: :alliance_associatons
  end
end