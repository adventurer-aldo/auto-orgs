class Sunny
  class VoteReminderJob < Que::Job
    self.run_at = Time.now + (60 * 60 * 22)

    def run(council_id)

      council = Council.find_by(id: council_id)
      council.votes.select { |vote| vote.votes.include?(0) }.map(&:player).each do |player|
        BOT.channel(player.submissions).send_message("Reminder to vote #{BOT.user(player.user_id).mention}")
      end
      destroy
    end
  end
end