class Sunny
  class HuntJob < Que::Job
    self.run_at = proc { Time.now + 3 * 60 * 60 } # 10 minutes from now

    def run
      # Call your results reveal/update method
      Sunny.reveal_results_and_update if Sunny::Challenges::Individual.where(start_time: nil).where.not(stage: 0).exists?

      destroy
    end
  end
end
