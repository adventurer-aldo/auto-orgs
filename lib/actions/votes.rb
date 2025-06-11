class Sunny
  BOT.command :vote, description: 'Vote a castaway for Tribal Council' do |event, *args|
    # ===========================================================================================
    # Once votes are TOTAL_ALLOWED_VOTES == SUBMITTED VOTES, then enter Lock phase.
    # Once you lock, the Bot will make tribal council by itself.
    # It does not mean you can't change votes anymore. It merely means it will start early, unless
    # you need to rethink of something.
    break unless event.user.id.player?

    player = if [0, 1].include? Setting.last.game_stage
               Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: ALIVE)
             else
               Player.find_by(user_id: event.user.id, season_id: Setting.last.season, status: 'Jury')
             end
    break unless event.channel.id == player.submissions

    vote = Vote.where(player_id: player.id)
    council = Council.where(id: vote.map(&:council), stage: [0,1,3], season_id: Setting.last.season)
    break unless vote.exists? && council.exists?

    council = council.last
    council_votes = council.votes.map(&:votes).flatten
    updater = Vote.where(council_id: council.id).and(vote)
    vote = updater.first

    allowed_votes = vote.allowed
    if allowed_votes <= 0
      event.respond('You do not have any votes!')
    else
      voted = vote.votes
      parchments = vote.parchments
      enemies = Vote.where(council_id: council.id).excluding(Vote.where(player_id: player.id)).map(&:player).map { |n| Player.find_by(id: n, status: 'In') }
      enemies.delete(nil)
      options = enemies.map(&:id)

      content = ''
      number = 0
      if allowed_votes > 1 && args[0]
        number = args[0].to_i - 1
        number = 0 if number > allowed_votes - 1 || number.negative?

        content ||= args[1..]&.join(' ')
      elsif allowed_votes < 2 && args[0]
        content = args.map(&:downcase).join(' ')
      end

      if content == ''
        text = enemies.map do |en|
          "**#{en.id}** — #{en.name}"
        end

        event.channel.send_embed do |embed|
          embed.title = 'Who would you like to vote?'
          embed.description = text.join("\n")
          embed.color = event.server.role(player.tribe.role_id).color
        end

        event.user.await!(timeout: 40) do |await|
          content = await.message.content.downcase
          true
        end
      end

      target = nil
      text_attempt = enemies.map(&:name).filter { |nome| nome.downcase.include? content.downcase }
      id_attempt = options.filter { |id| id == content.to_i }
      if text_attempt.size == 1
        target = Player.find_by(name: text_attempt[0], season_id: Setting.last.season, status: ALIVE)
        voted[number] = target.id
      elsif id_attempt.size == 1
        target = Player.find_by(id: id_attempt[0])
        voted[number] = id_attempt[0]
      elsif content != ''
        event.respond("There's no single castaway that matches that.")
      end

      event.respond('Timed out! Take your time to decide who you really want to vote.') if content == '' || (text_attempt.size != 1 && id_attempt.size != 1)
      break if content == '' || (text_attempt.size != 1 && id_attempt.size != 1)

      if voted == vote.votes && content != ''
        image = nil
        if event.message.attachments.empty?
          event.respond('Time to upload a parchment!')
          file = URI.parse(PARCHMENT).open
          BOT.send_file(event.channel, file, filename: 'parchment.png')
          image = event.user.await!(timeout: 120)
        else
          image = event
        end

        if image
          unless image.message.attachments.empty?
            parch = image.message.attachments.first.url
            if parch =~ /.*\.[pj][np]g/
              parchments[number] = parch
              event.respond('**Got your parchment!**')
            else
              event.respond "I couldn't find a parchment there..."
            end
          else
            parch = image.message.content[/https:\/\/cdn\.discordapp\.com\/attachments.*\.[pj][np]g/]
            parch = image.message.content[/https:\/\/media\.discordapp\.net\/attachments.*\.[pj][np]g/] if parch.nil?
            if !parch.nil?
              parchments[number] = parch
              event.respond('**Got your parchment!**')
            else
              event.respond "I couldn't find a parchment there..."
            end
          end
        else
          event.respond "I couldn't find a parchment there..."
        end
        updater.update(votes: voted, parchments:)
        event.respond("You're now voting **#{target.name}**.")
        new_council_votes = council.votes.reload.map(&:votes).flatten
        BOT.channel(council.channel_id).send_message("#{new_council_votes.size - new_council_votes.count(0)}/#{new_council_votes.size}") unless new_council_votes.count(0) == council_votes.count(0)
      else
        'No vote was submitted...'
      end
    end
  end
end
