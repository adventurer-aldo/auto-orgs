class Sunny
  ADMIN_HELP = {
    'Season Setup' => {
      admin_help: ['!admin_help [command]', 'Show host command categories, or details for one command.'],
      season: ['!season NAME', 'Create a new season and make it current.'],
      players: ['!players @user...', 'Register castaways for the current season. With no mentions, opens a user picker.'],
      tribes: ['!tribes @role @role...', 'Split alive castaways into the mentioned tribe roles.'],
      ftc: ['!ftc', 'Begin Final Tribal Council.'],
      episode_title: ['!episode_title @quote_owner quote text', 'Set the current episode title and open the next episode.'],
      add_image: ['!add_image [player_id]', 'Attach the uploaded image to a castaway. With no ID, opens a castaway picker.'],
      cast_image: ['!cast_image [season_id]', 'Post the season cast image.']
    },
    'Spectator Games' => {
      set_spectator_channel: ['!set_spectator_channel draft|elimination|bootlist [channel_id]', 'Set a spectator game channel. Leave channel_id blank to use the current channel.'],
      prepare_draft: ['!prepare_draft', 'Open the Draft Game in the configured draft channel.'],
      prepare_elimination: ['!prepare_elimination', 'Open the Elimination Game in the configured elimination channel.'],
      prepare_bootlist: ['!prepare_bootlist', 'Open the Bootlist Game in the configured bootlist channel.'],
      draft: ['!draft', 'Post the current Draft Game board.'],
      eliminator: ['!eliminator', 'Post the current Elimination Game board.'],
      bootlist: ['!bootlist', 'Post the current Bootlist Game board.']
    },
    'Tribal Council' => {
      council: ['!council @tribe...', 'Create Tribal Council for the mentioned tribe role(s).'],
      cancel_tribal: ['!cancel_tribal [all|@tribe|tribe name]', 'Cancel Tribal Council. With no argument, cancels this council channel.'],
      count: ['!count', 'Force a vote count in the current Tribal Council channel.'],
      eliminate: ['!eliminate [castaway]', 'Eliminate a castaway. With no argument, opens a castaway picker.'],
      rocks: ['!rocks [in]', 'Run a rocks elimination in the current Tribal Council channel.'],
      immunity: ['!immunity @role|@user...', 'Grant immunity to members of mentioned roles and mentioned users.']
    },
    'Items' => {
      item: ['!item', 'Create an item. With no arguments, opens the item creation modal.'],
      remove_item: ['!remove_item [code]', 'Delete a current-season item. With no code, opens an item picker.'],
      items: ['!items [season_id]', 'List items for a season.']
    },
    'Server Admin' => {
      add_host: ['!add_host @user|USER_ID...', 'Give users host permissions.'],
      remove_host: ['!remove_host @user|USER_ID|name', 'Remove host permissions.'],
      set_archive: ['!set_archive CATEGORY_ID', 'Set the archive category.'],
      archive: ['!archive [all]', 'Archive this channel, or all channels in this category.'],
      prune: ['!prune', 'Delete up to 100 messages from this channel.'],
      update: ['!update', 'Refresh generated item commands.'],
      reset: ['!reset', 'Delete current season data after confirmation.'],
      set_parchment_url: ['!set_parchment_url URL', 'Set the default parchment image URL.'],
      message_logging: ['!message_logging on|off', 'Enable or disable edit/delete message logging.']
    },
    'Roles And Channels' => {
      add_roles: ['!add_roles @user... @role...', 'Add mentioned roles to mentioned users.'],
      remove_roles: ['!remove_roles @role...', 'Remove mentioned roles from every member who has them.'],
      delete_roles: ['!delete_roles @role|ROLE_ID...', 'Delete unused roles after confirming.'],
      joint_dms: ['!joint_dms', 'Create joint DM channels for close castaway pairs.'],
      create_dms: ['!create_dms', 'Create player DM channels.'],
      disband: ['!disband', 'Disband the alliance channel this is run in.']
    },
    'Challenges' => {
      hot_potato: ['!hot_potato', 'Start Hot Potato.'],
      explode: ['!explode', 'Force the current Hot Potato explosion.'],
      fibb: ['!fibb', 'Start Fibbage.'],
      results: ['!results', 'Show Fibbage results.'],
      real_results: ['!real_results', 'Show the full Fibbage answer results.'],
      grid: ['!grid', 'Show Battleships grids.'],
      battleships: ['!battleships', 'Start Battleships.'],
      restartship: ['!restartship', 'Reset Battleships ship placement.']
    },
    'Info' => {
      info: ['!info', 'Show current player organization info.'],
      season_timer: ['!season_timer', 'Show current season timing info.'],
      get_image: ['!get_image PLAYER_ID', 'Post a castaway image.'],
      legacy_item_plays: ['!legacy_item_plays', 'Sort a legacy item play into the current event feed.']
    }
  }.freeze

  def self.admin_help_lookup
    ADMIN_HELP.values.reduce({}) do |memo, commands|
      commands.each { |name, help| memo[name.to_s] = help }
      memo
    end
  end

  BOT.command :admin_help do |event, *args|
    break unless event.user.id.host?

    query = args.join(' ').downcase.delete_prefix('!').strip
    help = admin_help_lookup[query]

    event.channel.send_embed do |embed|
      embed.color = event.user.on(event.server).color

      if help
        embed.title = help.first
        embed.description = help.last
      else
        embed.title = 'Host Commands'
        embed.description = 'Use `!admin_help command` for details.'
        embed.fields = ADMIN_HELP.map do |category, commands|
          names = commands.keys.map { |command| "`!#{command}`" }.join(', ')
          Discordrb::Webhooks::EmbedField.new(name: category, value: names)
        end
      end
    end
  end
end
