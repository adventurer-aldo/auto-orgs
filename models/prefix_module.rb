module Challenges
  def self.table_name_prefix
    "challenges_"
  end

  module Battleships
    def self.table_name_prefix
      "battleships_"
    end
  end
end

module SpectatorGame
  def self.table_name_prefix
    "spectator_game_"
  end
end

module Alliances
  def self.table_name_prefix
    "alliances_"
  end
end