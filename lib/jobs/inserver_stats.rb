class Sunny
  class InServerStats < Que::Job

    self.run_at = proc { Time.now + (60 * 60 * 24)}

    def run
      player_size = Player.where(status: ALIVE, season: Setting.last.season).size
      BOT.channel(target_channel).send_message "Day #{((Time.now.to_i - BOT.channel(1322130194726649956).load_message(1381717169812803704).timestamp.to_i) / 60 / 60 / 24)} - F#{player_size}"

      enqueue if player_size > 3
      destroy
    end

  end
end