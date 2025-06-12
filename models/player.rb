class Player < ActiveRecord::Base
  # =========================================================================
  # Statuses are:
  # =========================================================================
  # Immune
  # Cannot be voted, but can vote if present at tribal council.
  # Also In.
  #
  # Idoled
  # Can be voted and can be voted if present at TC, but votes against will not be counted.
  # Also In.
  #
  # In
  # Can be voted and can be voted if present at TC.
  # Participates in challenges, alliances and tribes-
  #
  # Jury
  # Can only vote at FTC.
  #
  # Out
  # No powers at all.
  #
  # Exiled
  # Is In, but does not participate in anything other than challenges.
  belongs_to :season, foreign_key: 'season_id'
  belongs_to :tribe, foreign_key: 'tribe_id'
  has_many :buddies, foreign_key: 'player_id'
  has_many :items, foreign_key: 'player_id'
  has_many :mazes, foreign_key: 'player_id'
  has_many :votes, foreign_key: 'player_id'
end
