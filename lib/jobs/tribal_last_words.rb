class Sunny
  class TribalLastWordsTimer < Que::Job
    self.run_at = proc { Time.now + 60 * 10 }

    # 0 == VOTE TALLY
    # 1 == ROCKS
    def run(id, council_id, rocks=false)
      council = Council.find_by(id: council_id)
      loser = Player.find_by(id:)
      channel = BOT.channel(council.channel_id)
      channel.send_message("**#{loser.name}...The #{rocks ? 'rocks have' : 'tribe has'} spoken.**")
      file = URI.parse('https://i.ibb.co/zm9tYcb/spoken.gif').open
      BOT.send_file(channel, file, filename: 'spoken.gif')
      # Open camps and stuff.
      council_tribes = council.tribes.map { |r| Tribe.find_by(id: r) }
      council_tribes.each do |tribed|
        BOT.channel(tribed.channel_id).define_overwrite(BOT.server(ALVIVOR_ID).role(tribed.role_id), 3072, 0)
        BOT.channel(tribed.channel_id).send_message("**Open!**")
        BOT.channel(tribed.cchannel_id).define_overwrite(BOT.server(ALVIVOR_ID).role(tribed.role_id), 3072, 0)
        BOT.channel(tribed.cchannel_id).send_message("**Open!**")
      end
      destroy
    end
  end
end