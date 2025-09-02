module Alliances
  class Group < ActiveRecord::Base
    has_many :associations, foreign_key: 'alliance_id', class_name: 'Alliances::Association', dependent: :destroy
    has_many :players, through: :associatons
  end
end