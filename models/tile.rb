class Tile < ActiveRecord::Base
  belongs_to :maze, foreign_key: 'maze_id'
end
