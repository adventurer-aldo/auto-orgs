class Sunny
  class TestJob < Que::Job
    self.run_at = proc { Time.now + 60 }

    def run
      BOT.channel(HOST_CHAT).send_message('Hi.')
      destroy
    end
  end
end