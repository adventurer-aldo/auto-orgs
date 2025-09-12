class Sunny
  class PotatoJob < Que::Job
    self.run_at = proc { Time.now + (144 * 60) } # 2 hours 11 minutes from now

    def run
      # Call your results reveal/update method
      Sunny.explode_potato

      destroy
    end
  end
end