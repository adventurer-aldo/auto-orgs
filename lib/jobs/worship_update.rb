class Sunny
  class WorshipUpdateJob < Que::Job
    self.run_at = proc { Time.now + (5 * 60)}

    def run
      score_strings = Setting.last.tribes.map do |tribe_id|
        t = Tribe.find_by(id: tribe_id)
        "#{t.name} — #{t.challenges.first.end_time} Points"
      end
      BOT.channel(1411757145036161044).load_message(1411785531901083782).edit("**Current Progress of the Challenge for both tribes:**\n#{score_strings.join("\n")}")
      WorshipUpdateJob.enqueue
    end
  end
end