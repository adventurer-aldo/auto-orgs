class Sunny
  class InServerStats < Que::Job

    self.run_at = proc { Time.now + (60 * 60 * 24)}

    def run
      season = Setting.last.season
      player_size = Player.where(status: ALIVE, season:).size
      BOT.channel(1388974050717732895).name = "Season #{season} - Day #{((Time.now.to_i - season.start_time.to_i) / 60 / 60 / 24)} - F#{player_size}"

      InServerStats.enqueue if player_size > 3
      destroy
    end

  end
end