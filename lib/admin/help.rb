class Sunny
  BOT.command :admin_help do |event|
    break unless event.user.id.host?

    fields = [
      ['!admin_help', 'Show this host-only command list.'],
      ['!add_host USER_ID', 'Give a user host permissions.'],
      ['!remove_host USER_ID', 'Remove host permissions from a user.'],
      ['!set_parchment_url URL', 'Set the default parchment image.'],
      ['!set_archive CATEGORY_ID', 'Set the archive category.'],
      ['!add_roles @user @role', 'Add one or more roles to mentioned users.'],
      ['!remove_roles @role', 'Remove mentioned roles from every member who has them.'],
      ['!delete_roles @role|ROLE_ID', 'Delete unused roles after confirming.'],
      ['!reset', 'Delete current season data and tribe/council channels after confirming.'],
      ['!item', 'Create an item, or open the item creation modal.'],
      ['!remove_item', 'Delete an item, with confirmation.'],
      ['!players', 'Register new season players.'],
      ['!tribes @role @role', 'Split remaining castaways into tribes.'],
      ['!council @tribe', 'Create a Tribal Council.'],
      ['!cancel_tribal [all|@tribe|tribe name]', 'Cancel a Tribal Council. No argument cancels this channel.'],
      ['!eliminate', 'Eliminate a castaway.'],
      ['!count', 'Force a vote count in the current Tribal Council channel.'],
      ['!rocks', 'Run a rocks elimination in the current Tribal Council channel.'],
      ['!archive', 'Archive a channel.']
    ].map { |name, value| Discordrb::Webhooks::EmbedField.new(name: name, value: value) }

    event.channel.send_embed do |embed|
      embed.title = 'Host commands'
      embed.description = 'Only hosts can use these commands.'
      embed.fields = fields
      embed.color = event.user.on(event.server).color
    end
  end
end
