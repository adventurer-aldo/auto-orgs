module SpectatorGame
  class Bootlist < ActiveRecord::Base
    def values
      column = Sunny.model_column(self.class, %w[rankings picks bootlist player_ids players])
      column ? Array(public_send(column)).map(&:to_i) : []
    end

    def score
      actual = Sunny.actual_boot_order_player_ids
      return 0 if actual.empty?

      actual.each_with_index.sum do |player_id, actual_index|
        predicted_index = values.index(player_id)
        predicted_index ? (predicted_index - actual_index).abs : actual.size
      end
    end
  end
end
