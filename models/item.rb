class Item < ActiveRecord::Base
  EARLY_FUNCTIONS = %w[
    safety_without_power
  ].freeze

  NOW_FUNCTIONS = %w[
    extra_vote
    steal_vote
    block_vote
  ].freeze

  TALLIED_FUNCTIONS = %w[
    idol
  ].freeze

  belongs_to :season, foreign_key: 'season_id'
  belongs_to :player, foreign_key: 'player_id'

  def early?
    (Array(functions) & EARLY_FUNCTIONS).any?
  end

  def now?
    (Array(functions) & NOW_FUNCTIONS).any?
  end

  def tallied?
    (Array(functions) & TALLIED_FUNCTIONS).any?
  end

  def idol?
    Array(functions).include?('idol')
  end
end
