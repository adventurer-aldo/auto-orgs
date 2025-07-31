class Sunny
  class CouncilStageChange < Que::Job
    self.run_at = proc { Time.now + 60 * 60 * 2 }

    def run(id)
      council = Council.find_by(id:)
      channel = BOT.channel(council.channel_id)

      channel.send_message("2 hours have now passed. **Immunity** is no longer transferable.")
      council.update(stage: 1)
      destroy
    end
  end
end