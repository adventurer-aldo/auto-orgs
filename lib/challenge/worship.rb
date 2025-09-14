class Sunny
  Tribe.where(id: Setting.tribes).pluck(:cchannel_id).each do |channel_id|
    BOT.message(in: channel_id) do |event|
      break unless event.user.id.player?
      
      player = Player.find_by(user_id: event.user.id, season: Setting.season)
      tribe = player.tribe
      challenge = Challenges::Tribal.find_by(tribe_id: tribe.id)
      
      correct = false
      if tribe.id == 25 # Uada
        case challenge.stage
        when 0
          if event.message.content == 'I worship Idan.'
            challenge.update(end_time: challenge.end_time + 1, stage: 1) 
            correct = true
          end
        when 1
          if event.message.content == 'Idan lives on within us.'
            challenge.update(end_time: challenge.end_time + 1, stage: 0) 
            correct = true
          end
        end
      elsif tribe.id == 26 # Habiti
        case challenge.stage
        when 0
          if event.message.content == 'I worship Isaiah.'
            challenge.update(end_time: challenge.end_time + 1, stage: 1) 
            correct = true
          end
        when 1
          if event.message.content == 'May they be reborn anew.'
            challenge.update(end_time: challenge.end_time + 1, stage: 0) 
            correct = true
          end
        end
      end
      event.message.create_reaction('✅') if correct == true
    end
  end
end