class Maze < ActiveRecord::Base
  belongs_to :player, foreign_key: 'player_id'
  has_many :tiles, foreign_key: 'maze_id'
end
