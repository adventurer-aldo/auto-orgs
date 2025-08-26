class Sunny
  class CouncilCountJob < Que::Job
    self.run_at = proc { Time.now + (60 * 60 * 24) }

    def run(id)
      council = Council.find_by(id:)
      return if council.nil?
      return unless [1, 3].include? council.stage

      loser = nil
      seed = nil
      roles = council.tribes.map { |r| BOT.server(ALVIVOR_ID).role(Tribe.find_by(id: r).role_id) }
      roles << BOT.server(ALVIVOR_ID).role(TRIBAL_PING)
      channel = BOT.channel(HOST_CHAT)
      channel.send_message("**Welcome #{roles.map(&:mention).join(' ').to_s}**")
      channel.start_typing
      sleep(2)
      rank = Player.where(season_id: Setting.last.season, status: ALIVE).size
      total = Player.where(season_id: Setting.last.season).size
      if council.stage > 2
        channel.send_message("**It's time to read the votes, once again!**")
        channel.start_typing
        council.update(stage: 4)
      else
        channel.send_message("**It is now time for the F#{rank} read-off!**")
        council.update(stage: 2)
        channel.start_typing
      end
      sleep(2)
      channel.send_message('Your votes are now locked in and unable to be changed.')
      channel.start_typing
      sleep(1)
      channel.send_message('...')
      channel.start_typing
      sleep(2)
      channel.send_message("...I'll go tally the votes.")
      sleep(10)
      channel.start_typing
      sleep(3)
      channel.start_typing
      sleep(2)
      channel.send_message('...')
      all_votes = []
      all_counted_votes = []
      counted_votes = []
      vote_count = {}
      parchments = {}

      voters = council.votes
      voters.each do |vote|
        sub = vote.votes.map do |mapping|
          if mapping.zero? && council.stage == 4
            nil
          elsif mapping.zero?
            channel.start_typing
            sleep(2)
            channel.send_message("**#{vote.player.name} has self-voted!**")
            vote.player.id
          else
            mapping
          end
        end

        sub.delete(nil)

        vote.update(votes: sub)
        all_votes += sub
        vote_count[vote.player.id] = 0
        parchments[vote.player.id] = []
      end
      voters.each do |vote|
        vote.votes.each_with_index do |ret, index|
          parchments[ret] << vote.parchments[index]
        end
      end
      parchments.each do |key, _value|
        parchments[key].sort_by!(&:length)
      end
      all_votes.shuffle!
      majority = (Float(all_votes.size + 1) / 2.0).round

      if council.stage == 2 && rank > 5
        channel.start_typing
        sleep(5)
        channel.send_message(rank == 5 ?  'Now, for the last time... If anyone has a **Hidden Immunity Idol** and would like to `!play` it...' : 'Now, if anyone has a **Hidden Immunity Idol** and would like to `!play` it...')
        channel.start_typing
        sleep(3)
        channel.send_message('This is the time to do it in your submissions channel.')

        i = 0
        max = 6

        while i < max
          i += 1
          items = Item.where(timing: 'Tallied', season_id: Setting.last.season).excluding(Item.where(player_id: nil)).excluding(Item.where(targets: []))
          if items.exists?
            max += 6
            items.map.each do |item|
              owner = item.player
              targets = item.targets.map { |n| Player.find_by(id: n, status: ALIVE) }

              item.update(player_id: nil, targets: [])
              channel.start_typing
              sleep(1)
              channel.send_message("**#{owner.name} stands!**")
              channel.start_typing
              sleep(4)
              channel.send_message("*\"I'd like to play this on **#{targets.map(&:name).join('**, **').gsub(owner.name, 'myself')}**\"*")
              channel.send_embed do |embed|
                embed.title = item.name
                embed.description = item.description
                embed.color = BOT.server(ALVIVOR_ID).role(TRIBAL_PING).color
              end
              item.functions.each do |function|
                case function
                when 'idol'
                  channel.start_typing
                  sleep(2)
                  channel.send_message('This is a valid item!')
                  channel.start_typing
                  sleep(3)
                  channel.send_message("**Any votes casted for #{targets.map(&:name).join(' or ')} will NOT count!**")
                  targets.each do |player|
                    player.update(status: 'Idoled')
                  end
                end
              end
              channel.start_typing
              sleep(3)
              channel.send_message('...')
              channel.start_typing
              sleep(3)
              channel.send_message('Anyone else?')
            end
          else
            channel.start_typing
            sleep(5)
            channel.send_message('...')
          end
        end
      end
      precounted_votes = all_votes
      precounted_votes -= Player.where(status: 'Idoled', season_id: Setting.last.season).map(&:id)
      unless precounted_votes == []
        all_votes.insert((all_votes.size - 1), all_votes.delete_at(all_votes.index(precounted_votes.max_by { |i| precounted_votes.count(i)})))
      end

      channel.start_typing
      sleep(4)
      channel.send_message('Alright. Once the votes are read, the decision is final and the castaway voted off will be asked to leave the Tribal Council area immediately.')
      channel.start_typing
      sleep(2)
      channel.send_message('...')

      loop do
        if all_votes.size > 1 && vote_count[all_votes[0]] + 1 != majority
          channel.start_typing
          sleep(2)
          channel.send_message("#{COUNTING[all_counted_votes.size]} vote...")
          sleep(2)
          lame = ' (NO PARCHMENT)'
          unless parchments[all_votes[0]][0] == '0'
            begin
              file = URI.parse(parchments[all_votes[0]][0]).open
              filenam = '.png'
              filenam = '.jpg' if filenam.include? '.jpg'
              BOT.send_file(channel, file, filename: "parchment#{filenam}")
              lame = ''
            rescue OpenURI::HTTPError

            end
            channel.start_typing
            sleep(2)
          end
          parchments[all_votes[0]].delete_at(0)
          votee = Player.find_by(id: all_votes[0])
          channel.send_message("#{BOT.user(votee.user_id).mention}#{lame}")
          if votee.status == 'Idoled'
            channel.start_typing
            sleep(2)
            channel.send_message('**Does not count!**')
          else
            counted_votes += [all_votes[0]]
            vote_count[all_votes[0]] += 1
          end
          all_counted_votes += [all_votes[0]]
          all_votes.delete_at(0)
          channel.start_typing
          sleep(2)
          if vote_count.values.count(vote_count.values.max) > 1 || (counted_votes.size % 4).zero?
            revel = []
            unless counted_votes.empty?
              vote_count.sort_by { |_n, k| k }.reverse.each do |k, v|
                if v == 1
                  revel << "#{v} vote #{Player.find_by(id: k).name}"
                elsif v > 1
                  revel << "#{v} votes #{Player.find_by(id: k).name}"
                end
              end
              revel = "That's #{revel.join(', ')}"
              channel.send_message(revel)
              channel.start_typing
              sleep(2)
              if all_votes.size > 1
                channel.send_message("**#{all_votes.size} votes left.**")
              end
            end
            if all_votes.size == 1
              channel.send_message(['**ONE VOTE LEFT**', '**ONLY ONE VOTE LEFT**', '**IT ALL COMES DOWN TO THE LAST VOTE**'].sample)
            end
          end
        elsif all_votes.size == 1 || vote_count[all_votes[0]] + 1 == majority
          channel.start_typing
          sleep(2)
          case Setting.last.game_stage
          when 0
            channel.send_message("**The #{COUNTING[total - rank]} castaway eliminated from Alvivor Season 3: Spirits & Souls is...**")
          when 1
            channel.send_message("**#{COUNTING[total - rank]} castaway eliminated from Alvivor Season 3: Spirits & Souls and #{COUNTING[Player.where(status: 'Jury', season_id: Setting.last.season).size].downcase} member of the Jury is...**")
          end
          sleep(5)
          lame = ' (NO PARCHMENT)'
          unless parchments[all_votes[0]][0] == ''
            begin
              file = URI.parse(parchments[all_votes[0]][0]).open
              filenam = '.png'
              filenam = '.jpg' if filenam.include? '.jpg'
              BOT.send_file(channel, file, filename: "parchment#{filenam}")
              lame = ''
            rescue OpenURI::HTTPError

            end
            channel.start_typing
            sleep(2)
          end
          parchments[all_votes[0]].delete_at(0)
          votee = Player.find_by(id: all_votes[0])
          channel.send_message("#{BOT.user(votee.user_id).mention}#{lame}")
          all_counted_votes += [all_votes[0]]

          votee = Player.find_by(id: all_votes[0])
          if votee.status == 'Idoled'
            channel.start_typing
            sleep(2)
            channel.send_message('**Does not count!**')
          else
            counted_votes += [all_votes[0]]
            vote_count[all_votes[0]] += 1
          end
          all_votes.delete_at(0)
          channel.start_typing
          sleep(2)
          if vote_count.values.count(vote_count.values.max) > 1
            channel.send_message(["**We're tied!**", '**To be determined!**', '**is still unknown!**'].sample)
            channel.start_typing
            sleep(3)
            channel.send_message(["Here's how we'll do this.", "Alright, let's do something about this...", 'Bummer. Here is what we will do next...'].sample)
            channel.start_typing
            if rank == 4
              sleep(3)
              channel.send_message("We'll do a **Firemaking Challenge.**")
              channel.start_typing
              sleep(3)
              channel.send_message('The winner will get to move on to the **Final 3**.')
              channel.send_message("#{BOT.user(HOSTS.sample).mention} can take it from here.")
            else
              sleep(3)
              case council.stage
              when 2
                council.update(stage: 3)
                channel.send_message('Everyone but the tied up castaways will enter in a revote, each with only one available vote.')
                channel.start_typing
                sleep(3)
                channel.send_message('You will only be able to vote the castaways tied.')

                Player.where(season_id: Setting.last.season, status: 'Idoled').update(status: 'Immune')
                immunes = Player.where(status: 'Immune', season_id: Setting.last.season).map(&:id)

                vote_count.each do |k,v|
                  if v == vote_count.values.max && Player.where(id: k, status: ['Idoled', 'Immune'], season_id: Setting.last.season).exists? == false
                    Vote.find_by(player_id: k, council_id: council.id).update(allowed: 0, votes: [])
                  else
                    Vote.find_by(player_id: k, council_id: council.id).update(allowed: 1, votes: [0])
                  end
                end
                Vote.where(council_id: council.id, allowed: 1).excluding(Vote.where(player_id: immunes)).each do |revote|
                  Player.find_by(id: revote.player).update(status: 'Idoled')
                end
                channel.send_message("Vote between **#{Vote.where(council_id: council.id, allowed: 0).map { |n| Player.find_by(id: n.player).name}.join('** or **')}**.\nLet's get to it!")
              when 4
                channel.start_typing
                sleep(3)
                channel.send_message("We'll be drawing **ROCKS**")
                channel.start_typing
                sleep(3)
                channel.send_message("The castaways who earned Immunity or are protected by a Hidden Immunity Idol are exempt from drawing rocks.")
                channel.start_typing
                sleep(3)
                channel.send_message("Inside a :moneybag: are **white rocks** and **purple rocks**, which each castaway must blindly draw from it.")
                channel.start_typing
                sleep(3)
                channel.send_message('The castaway that draws the purple rock will be out of the game **immediately**.')
                channel.start_typing
                sleep(3)
                Player.where(status: 'In', season_id: Setting.last.season).update(status: 'Immune')
                seeds = Player.where(status: 'Idoled', season_id: Setting.last.season)
                channel.send_message("This will be between #{seeds.map(&:name).join(', ')}")
                channel.start_typing
                sleep(3)
                channel.send_message("Let's get to it!")
                rocks = seeds.map { |n| 0 }
                rocks[0] = 1
                rocks.shuffle!
                seeds.each do |seedy|
                  channel.start_typing
                  sleep(3)
                  channel.send_message("#{seedy.name} draws a rock...")
                  channel.start_typing
                  sleep(3)
                  channel.send_message('...')
                  channel.start_typing
                  sleep(3)
                  if rocks[seeds.index(seedy)].zero?
                    channel.send_message("It's a white rock! #{seedy.name} is safe.")
                  else
                    channel.send_message('...')
                    channel.start_typing
                    sleep(3)
                    channel.send_message("It's a **purple rock**.")
                    channel.start_typing
                    sleep(3)
                    channel.send_message("Unfortunately, **#{seedy.name}** is now out of the game.")
                    seed = seedy
                  end
                  return unless rocks[seeds.index(seedy)].zero?
                end
              end
            end
          else
            loser = Player.find_by(id: vote_count.keys[vote_count.values.index(vote_count.values.max)])
            channel.start_typing
            sleep(3)
            channel.send_message("It's time to go.")
            channel.start_typing
            sleep(3)
            channel.send_message('Any final words?')
            TribalLastWordsTimer.enqueue(loser.id, council.id)
          end
        end
        return if vote_count.values.max == majority || all_votes.size.zero?
      end
      return if (vote_count.values.count(vote_count.values.max) > 1) && council.stage < 4

      loser ||= seed
      eliminate(loser, event)
      council.update(stage: 5)
      destroy
    end
  end
end