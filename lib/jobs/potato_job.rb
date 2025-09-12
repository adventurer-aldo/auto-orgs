class Sunny
  class PotatoJob < Que::Job
    self.run_at = proc { Time.now + (2 * 3600) + (11 * 60) } # 2 hours 11 minutes from now

    def run
      # Call your results reveal/update method
      Sunny.explode_potato if Sunny::Challenges::Participant.where(status: 1).size > 1

      destroy
    end
  end
end