class Sunny
  # > Item
  # > Council

  BOT.command :get_items do |event|
    Item.all.map { |item|  "#{item.name}, owned by #{[0, nil].include?(item.player_id) ? 'no one' : item.player.name } in Season #{item.season_id} — Code: `#{item.code}`"}.join("\n")
  end

  BOT.command :item, description: "Creates a new item to be claimed." do |event, *args|
    break unless HOSTS.include? event.user.id

    event.respond "What is the type?\n**Early | Now | Tallied | Idoled | Super**"
    type = event.user.await!(timeout: 40).message.content.downcase

    event.respond("That's not immediate or queue...") unless %w[n i t s].include? type
    break unless %w[e n i t s].include? type

    case type
    when 'e'
      type = 'Early'
    when 'n'
      type = 'Now'
    when 't'
      type = 'Tallied'
    when 'i'
      type = 'Idoled'
    when 's'
      type = 'Super'
    end

    event.respond 'What is/are the function codes?'
    functions = event.user.await!(timeout: 40).message.content.downcase.split(' ')

    checked = true
    functions.each do |function|
      checked = false if DEFINED_FUNCTIONS.include?(function) == false
      break if DEFINED_FUNCTIONS.include?(function) == false
    end

    event.respond 'One or more of the submitted functions does not exist!' if checked == false
    break if checked == false

    event.respond("**What's the name?**")
    name = event.user.await!(timeout: 70).message.content

    event.respond("**What's the description?**")
    description = event.user.await!(timeout: 80).message.content

    event.respond("**To which tribe will this be restricted to?**")
    owner_role = event.user.await!(timeout: 80).message.role_mentions.first
    if !owner_role.nil?
      found_owner_role = Tribe.where(role_id: owner_role.id)
      own_restriction = if found_owner_role.exists?
                          event.respond("**This item will be restricted to #{found_owner_role.first.name} tribe.**")
                          found_owner_role.first.id
                        else
                          event.respond("**This item is not restricted to any tribe.**")
                          0
                        end
      puts own_restriction
    end

    event.respond('**And lastly, what will be the code?**')
    code = event.user.await!(timeout: 50).message.content.gsub(' ', '_')

    condition = Item.where(code:, season_id: Setting.season).exists?

    event.respond('An item with this code already exists!') if condition == true
    break if condition == true

    item = Item.create(code:, name:, description:, timing: type, functions:, own_restriction:, season_id: Setting.season)
    make_item_commands
    event.respond '**Your item has been created!**'

    event.channel.send_embed do |embed|
      embed.title = item.name
      embed.description = "**Code:** `#{item.code}`\n"
      embed.description << "**Description:** #{item.description}\n"
      embed.description << "**Restricted To:** #{item.own_restriction == 0 ? "No One" : Tribe.find_by(id: item.own_restriction).name + ' tribe' }" 
    end
  end
end
