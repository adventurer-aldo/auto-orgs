class Sunny
  RESULT_CHANNEL_ID = 13_863_891_883_870_126_68

  BOT.message do |event|
    break unless event.user.id.player?
    player = Player.find_by(user_id: event.user.id)

    indiv = Individual.find_by(player_id: player.id)
    break unless indiv
    break if indiv.stage == 0

    nil_count_before = Individual.where.not(start_time: nil).size

    # Allowed channels for participation
    channels = Player.where(id: Individual.all.pluck(:player_id))
                     .map { |p| [p.confessional, p.submissions] }
                     .flatten
    break unless channels.include?(event.channel.id)

    # Don't process if all have chosen actions (start_time NOT nil)
    all_actions_chosen = Individual.where(start_time: nil).where.not(stage: 0).exists?
    break unless all_actions_chosen

    content = event.message.content.downcase
    action = nil
    %w[attack counter ambush].each do |word|
      if content.include?(word) && action.nil?
        action = word
      end
    end
    break unless action

    action_code = { "attack" => 0, "counter" => 1, "ambush" => 2 }[action]

    if action == "counter"
      indiv.update(start_time: action_code, end_time: nil)
      event.respond "You're now countering any attacks."
    else
      alive_targets = Individual.where(stage: 1..6).map { |individual| [individual.player.name, individual.player.id] }
      target_entry = alive_targets.find { |name, _| content.include?(name.downcase) }
      next unless target_entry

      target_name, target_id = target_entry
      indiv.update(start_time: action_code, end_time: target_id)
      event.respond "You're now **#{action}ing** #{target_name}"
    end

    nil_count_after = Individual.where.not(start_time: nil).reload.size

    if nil_count_after != nil_count_before
      BOT.channel(RESULT_CHANNEL_ID).send_message("#{nil_count_after}/#{Individual.where.not(stage: 0).size}")
    end
    # After each update, check if all actions are in to reveal results
    unless Individual.where(start_time: nil).where.not(stage: 0).exists?
      reveal_results_and_update
    end
  end

  def self.reveal_results_and_update
    individuals = Individual.where.not(stage: 0)
    channel = BOT.channel(RESULT_CHANNEL_ID)

    # Prepare HP map from db stages (actual HP)
    hp_map = individuals.map { |ind| [ind.player_id, ind.stage.to_i] }.to_h

    channel.start_typing
    sleep 2
    channel.send_message("All actions have been received!")
    channel.start_typing
    sleep 2
    channel.send_message(".")

    counters = individuals.select { |i| i.start_time == 1 }
    attacks  = individuals.select { |i| i.start_time == 0 }
    ambushes = individuals.select { |i| i.start_time == 2 }

    counters.each do |indiv|
      channel.start_typing
      sleep 2
      channel.send_message("🛡️ **#{indiv.player.name}** decided to counter!")
    end

    attacks.each do |actor_indiv|
      actor = actor_indiv.player
      target = Player.find_by(id: actor_indiv.end_time)
      target_indiv = individuals.find { |i| i.player_id == target&.id }

      next unless target

      if target_indiv&.start_time == 1
        hp_map[actor.id] = [hp_map[actor.id] - 1, 0].max
        channel.start_typing
        sleep 2
        channel.send_message("⚔️ **#{actor.name}** attacked **#{target.name}**, who is countering. **#{actor.name}** received 1HP damage!")
        if hp_map[actor.id] == 0
          channel.start_typing
          sleep 2
          channel.send_message("💀 **#{actor.name}** has died!")
        end
      else
        hp_map[target.id] = [hp_map[target.id] - 1, 0].max
        channel.start_typing
        sleep 2
        channel.send_message("⚔️ **#{actor.name}** attacked **#{target.name}**. 1HP damage dealt!")
        if hp_map[target.id] == 0
          channel.start_typing
          sleep 2
          channel.send_message("💀 **#{target.name}** has died!")
        end
      end
    end

    ambushes.each do |actor_indiv|
      actor = actor_indiv.player
      target = Player.find_by(id: actor_indiv.end_time)
      target_indiv = individuals.find { |i| i.player_id == target&.id }

      next unless target

      if target_indiv&.start_time == 1
        hp_map[target.id] = [hp_map[target.id] - 2, 0].max
        channel.start_typing
        sleep 2
        channel.send_message("🌳 **#{actor.name}** ambushed **#{target.name}** successfully! 2HP damage dealt!")
        if hp_map[target.id] == 0
          channel.start_typing
          sleep 2
          channel.send_message("💀 **#{target.name}** has died!")
        end
      else
        channel.start_typing
        sleep 2
        channel.send_message("🌳 **#{actor.name}** ambushed **#{target.name}**, but **#{target.name}** didn't counter. Nothing happened...")
      end
    end

    # Update individuals' HP and reset start_time/end_time for next round
    individuals.each do |indiv|
      new_hp = hp_map[indiv.player_id]
      indiv.update(stage: new_hp, start_time: nil, end_time: nil)
    end

    # Check for eliminated tribes
    tribes = individuals.group_by { |i| i.player.tribe }
    tribes.each do |tribe, members|
      if members.all? { |m| m.stage == 0 }
        channel.start_typing
        sleep 2
        channel.send_message("**#{tribe.name.upcase}** has had both its members fall...")
      end
    end

    # Heart emojis by tribe name
    hearts_by_tribe = {
      "orca" => "💙",
      "panthera" => "💛",
      "serpentes" => "💜",
      "falco" => "❤️"
    }

    # Send HP embed
    embed = Discordrb::Webhooks::Embed.new(
      title: "Current HP of all players",
      color: 0xFF0000,
      fields: individuals.map do |i|
        tribe_name = i.player.tribe.name.downcase
        heart = hearts_by_tribe.find { |key, _| tribe_name.include?(key) }&.last || "❤️"
        hp = i.stage.to_i
        {
          name: "**#{i.player.name}** - #{hp} HP",
          value: heart * hp,
          inline: false
        }
      end
    )

    channel.send_embed("", embed)
    living = Individual.where.not(stage: 0).map { |individual| BOT.user(individual.player.user_id).mention }
    channel.send_message(living.join(" "))
    Que.clear!
    TestJob.enqueue
    channel.send_message("Results at <t:#{(Time.now.utc + 3 * 3600).to_i}:t>")
  end
end
