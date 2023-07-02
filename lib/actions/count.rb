class Sunny
  BOT.command :tribal, description: "Changes the Tribal Council stage to 1 (after 12h) to all those who have 0." do |event|
    break unless HOSTS.include? event.user.id

    if [0, 1].include? Setting.last.game_stage
      Council.where(stage: 0).update(stage: 1)
    else
      Council.where(stage: 0).update(stage: 2)
    end
    event.respond('The tribal stage has changed.')
    return
  end

  BOT.command :tribol, description: 'Changes the Tribal Council stage to 1 (after 12h) to all those who have 0.' do |event|
    break unless HOSTS.include? event.user.id
    Council.where(stage: 2).update(stage: 1)
    event.respond('The tribal stage has changed.')
    return
  end


  BOT.command :count, description: "Counts the votes inside a Tribal Council channel." do |event|
    break unless HOSTS.include? event.user.id

    council = Council.find_by(channel_id: event.channel.id)
    break if council.id.nil?
    break unless [1, 3].include? council.stage

    loser = nil
    seed = nil
    event.message.delete
    roles = council.tribe.map { |r| event.server.role(Tribe.find_by(id: r).role_id) }
    roles << event.server.role(TRIBAL_PING)
    event.respond("#{roles.map(&:mention).join(' ')}")
    event.channel.start_typing
    sleep(2)
    rank = Player.where(season_id: Setting.last.season, status: ALIVE).size
    total = Player.where(season_id: Setting.last.season).size
    if council.stage > 2
      event.respond("**It's time to read the votes, once again!**")
      event.channel.start_typing
      council.update(stage: 4)
    else
      event.respond("**It is time for the F#{rank} read-off!**")
      council.update(stage: 2)
      event.channel.start_typing
    end
    sleep(2)
    event.respond('Your votes can no longer be changed.')
    event.channel.start_typing
    sleep(1)
    event.respond('...')
    event.channel.start_typing
    sleep(2)
    event.respond("I'll go tally the votes.")
    sleep(10)
    event.channel.start_typing
    sleep(3)
    event.channel.start_typing
    sleep(2)
    event.respond('...')
    all_votes = []
    all_counted_votes = []
    counted_votes = []
    vote_count = {}
    parchments = {}

    voters = Council.votes
    voters.each do |vote|
      sub = vote.votes.map do |mapping|
        if mapping == 0
          event.channel.start_typing
          sleep(2)
          event.respond("**#{Player.find_by(id: vote.player).name} has self-voted!**")
          vote.player
        else
          mapping
        end
      end

      vote.update(votes: sub)
      all_votes += sub
      vote_count[vote.player] = 0
      parchments[vote.player] = []
    end
    voters.each do |vote|
      vote.votes.each_with_index do |ret, index|
        parchments[ret] << vote.parchments[index]
      end
    end
    parchments.each do |key, value|
      parchments[key].sort_by!(&:length)
    end
    all_votes.shuffle!
    majority = (Float(all_votes.size + 1)/2.0).round

    if council.stage == 2 && rank > 4
      event.channel.start_typing
      sleep(5)
      event.respond('Now, if anyone has a **Hidden Immunity Idol** and would like to `!play` it...')
      event.channel.start_typing
      sleep(3)
      event.respond('This is the time to do it in your submissions channel.')

      i = 0
      max = 10

      while i < max
        i += 1
        items = Item.where(timing: 'Tallied', season_id: Setting.last.season).excluding(Item.where(owner: 0)).excluding(Item.where(targets: []))
        if items.exists?
          max += 3
          items.map.each do |item|
            owner = Player.find_by(id: item.owner, status: ALIVE)
            targets = item.targets.map { |n| Player.find_by(id: n, status: ALIVE) }

            item.update(owner: 0, targets: [])
            event.channel.start_typing
            sleep(1)
            event.respond("**#{owner.name} stands!**")
            event.channel.start_typing
            sleep(4)
            event.respond("*\"I'd like to play this on **#{targets.map(&:name).join('**, **').gsub(owner.name,'myself')}**\"*")
            event.channel.send_embed do |embed|
              embed.title = item.name
              embed.description = item.description
              embed.color = event.server.role(TRIBAL_PING).color
            end
            item.functions.each do |function|
              case function
              when 'idol'
                event.channel.start_typing
                sleep(2)
                event.respond('This is a valid item!')
                event.channel.start_typing
                sleep(3)
                event.respond("**Any votes casted for #{targets.map(&:name).join(' or ')} will NOT count!**")
                targets.each do |player|
                  player.update(status: 'Idoled')
                end
              end
            end
            event.channel.start_typing
            sleep(3)
            event.respond('...')
            event.channel.start_typing
            sleep(3)
            event.respond('Anyone else?')
          end
        else
          event.channel.start_typing
          sleep(5)
          event.respond('...')
        end
      end
    end
    precounted_votes = all_votes
    precounted_votes -= Player.where(status: 'Idoled').map(&:id)
    unless precounted_votes == []
      all_votes.insert((all_votes.size - 1), all_votes.delete_at(all_votes.index(precounted_votes.max_by { |i| precounted_votes.count(i)})))
    end

    event.channel.start_typing
    sleep(4)
    event.respond('Alright. Once the votes are read, the decision is final and the castaway voted off will be asked to leave the Tribal Council area immediately.')
    event.channel.start_typing
    sleep(2)
    event.respond('...')

    loop do
      if all_votes.size > 1 && vote_count[all_votes[0]] + 1 != majority
        event.channel.start_typing
        sleep(2)
        event.respond("#{COUNTING[all_counted_votes.size]} vote...")
        sleep(2)
        lame = ' (NO PARCHMENT)'
        unless parchments[all_votes[0]][0] == ''
          begin
            file = URI.parse(parchments[all_votes[0]][0]).open
            filenam = '.png'
            filenam = '.jpg' if filenam.include? '.jpg'
            BOT.send_file(event.channel, file, filename: "parchment#{filenam}")
            lame = ''
          rescue OpenURI::HTTPError

          end
          event.channel.start_typing
          sleep(2)
        end
        parchments[all_votes[0]].delete_at(0)
        votee = Player.find_by(id: all_votes[0])
        event.respond("#{BOT.user(votee.user_id).mention}#{lame}")
        if votee.status == 'Idoled'
          event.channel.start_typing
          sleep(2)
          event.respond('**Does not count!**')
        else
          counted_votes += [all_votes[0]]
          vote_count[all_votes[0]] += 1
        end
        all_counted_votes += [all_votes[0]]
        all_votes.delete_at(0)
        event.channel.start_typing
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
            event.respond(revel)
            event.channel.start_typing
            sleep(2)
            if all_votes.size > 1
              event.respond("**#{all_votes.size} votes left.**")
            end
          end
          if all_votes.size == 1
            event.respond(['**ONE VOTE LEFT**', '**ONLY ONE VOTE LEFT**', '**IT ALL COMES DOWN TO THE LAST VOTE**'].sample)
          end
        end
      elsif all_votes.size == 1 || vote_count[all_votes[0]] + 1 == majority
        event.channel.start_typing
        sleep(2)
        case Setting.last.game_stage
        when 0
          event.respond("**The #{COUNTING[total - rank]} castaway eliminated from Maskvivor is...**")
        when 1
          event.respond("**#{COUNTING[total - rank]} castaway eliminated from Maskvivor and #{COUNTING[Player.where(status: 'Jury', season_id: Setting.last.season).size].downcase} member of the Jury is...**")
        end
        sleep(5)
        lame = ' (NO PARCHMENT)'
        unless parchments[all_votes[0]][0] == ''
          begin
            file = URI.parse(parchments[all_votes[0]][0]).open
            filenam = '.png'
            filenam = '.jpg' if filenam.include? '.jpg'
            BOT.send_file(event.channel, file, filename: "parchment#{filenam}")
            lame = ''
          rescue OpenURI::HTTPError

          end
          event.channel.start_typing
          sleep(2)
        end
        parchments[all_votes[0]].delete_at(0)
        votee = Player.find_by(id: all_votes[0])
        event.respond("#{BOT.user(votee.user_id).mention}#{lame}")
        all_counted_votes += [all_votes[0]]

        votee = Player.find_by(id: all_votes[0])
        if votee.status == 'Idoled'
          event.channel.start_typing
          sleep(2)
          event.respond('**Does not count!**')
        else
          counted_votes += [all_votes[0]]
          vote_count[all_votes[0]] += 1
        end
        all_votes.delete_at(0)
        event.channel.start_typing
        sleep(2)
        if vote_count.values.count(vote_count.values.max) > 1
          event.respond(["**We're tied!**", '**To be determined!**', '**is still unknown!**'].sample)
          event.channel.start_typing
          sleep(3)
          event.respond(["Here's how we'll do this.", "Alright, let's do something about this...", 'Bummer. Here is what we will do next...'].sample)
          event.channel.start_typing
          if rank == 4
            sleep(3)
            event.respond("We'll do a **Firemaking Challenge.**")
            event.channel.start_typing
            sleep(3)
            event.respond('The winner will get to move on to the **Final 3**.')
            event.respond("#{BOT.user(HOSTS.sample).mention} can take it from here.")
          else
            sleep(3)
            case council.stage
            when 2
              council.update(stage: 3)
              event.respond('Everyone but the tied up castaways will enter in a revote, each with only one available vote.')
              event.channel.start_typing
              sleep(3)
              event.respond('You will only be able to vote the castaways tied.')

              Player.where(season_id: Setting.last.season, status: 'Idoled').update(status: 'Immune')
              immunes = Player.where(status: 'Immune').map(&:id)

              vote_count.each do |k,v|
                if v == vote_count.values.max && Player.where(id: k, status: ['Idoled', 'Immune']).exists? == false
                  Vote.find_by(player_id: k, council_id: council.id).update(allowed: 0, votes: []) 
                else
                  Vote.find_by(player_id: k, council_id: council.id).update(allowed: 1, votes: [0]) 
                end
              end
              Vote.where(council_id: council.id, allowed: 1).excluding(Vote.where(player_id: immunes)).each do |revote|
                Player.find_by(id: revote.player).update(status: 'Idoled')
              end
              event.respond("Vote between **#{Vote.where(council_id: council.id, allowed: 0).map { |n| Player.find_by(id: n.player).name}.join('** or **')}**.\nLet's get to it!")
            when 4
              event.channel.start_typing
              sleep(3)
              event.respond("We'll be drawing **ROCKS**")
              event.channel.start_typing
              sleep(3)
              event.respond('The castaway that draws the purple rock will be out of the game immediately.')
              event.channel.start_typing
              sleep(3)
              Player.find_by(status: 'In').update(status: 'Immune')
              seeds = Player.where(status: 'Idoled')
              event.respond("This will be between #{seeds.map(&:name).join(', ')}")
              event.channel.start_typing
              sleep(3)
              event.respond("Let's get to it!")
              rocks = seeds.map { |n| 0 }
              rocks[0] = 1
              rocks.shuffle!
              seeds.each do |seedy|
                event.channel.start_typing
                sleep(3)
                event.respond("#{seedy.name} draws a rock...")
                event.channel.start_typing
                sleep(3)
                event.respond('...')
                event.channel.start_typing
                sleep(3)
                if rocks[seeds.index(seedy)].zero?
                  event.respond("It's a white rock! #{seedy.name} is safe.")
                else
                  event.respond('...')
                  event.channel.start_typing
                  sleep(3)
                  event.respond("It's a **purple rock**.")
                  event.channel.start_typing
                  sleep(3)
                  event.respond("Unfortunately, **#{seedy.name}** is now out of the game.")
                  seed = seedy
                end
                break unless rocks[seeds.index(seedy)].zero?
              end
            end
          end
        else
          loser = Player.find_by(id: vote_count.keys[vote_count.values.index(vote_count.values.max)])
          #event.respond("**#{loser.name}**")
          event.channel.start_typing
          sleep(3)
          event.respond("It's time to go.")
          event.channel.start_typing
          sleep(3)
          event.respond('Any final words?')
          sleep(300)
          event.respond("**#{loser.name}...The tribe has spoken.**")
          file = URI.parse('https://i.ibb.co/zm9tYcb/spoken.gif').open
          BOT.send_file(event.channel, file, filename: 'spoken.gif')
        end
      end
      break if vote_count.values.max == majority || all_votes.size.zero?
    end
    break if (vote_count.values.count(vote_count.values.max) > 1) && council.stage < 4

    loser ||= seed
    event.channel.define_overwrite(event.server.member(loser.user_id), 3072, 0)
    eliminate(loser, event)
    council.update(stage: 5)
    return
  end
end
