class Sunny
  class PotatoJob < Que::Job
    self.run_at = proc { Time.now + Sunny.next_potato_delay }

    def run
      # Call your results reveal/update method
      Sunny.explode_potato

      destroy
    end
  end
end
