class Sunny
  class VoteReminderJob < Que::Job
    self.run_at = Time.now + (60 * 60 * 22)

    def run(council_id)

      council = Council.find_by(id: council_id)
      council.votes.select { |vote| vote.votes.include?(0) }.map(&:player).each do |player|
        BOT.channel(player.submissions).send_message([
          "Reminder to vote",
          "Not much time left to submit a vote,",
          "You haven't voted yet,",
          "You forgot to vote",
          "Just reminding you that you still haven't voted",
          "Votes are being tallied not too late from now!",
          "Hey, just reminding you..that you still haven't voted yet",
          "Hmm... You know what's missing? Your vote"
        ].sample + " #{BOT.user(player.user_id).mention}")
      end
      destroy
    end
  end
end