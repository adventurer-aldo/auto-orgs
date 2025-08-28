module Alliances
  class Group < ActiveRecord::Base
    has_many :alliance_associatons, class_name: 'Alliances::Association', dependent: :destroy
    has_many :players, through: :alliance_associatons
  end
end