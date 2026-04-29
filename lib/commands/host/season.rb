class Sunny
  BOT.command :season, description: 'Creates a new season.' do |event, *args|
    break unless event.user.id.host?

    newseason = Season.create(name: args.join(' '))
    Setting.season_id = newseason.id
    Setting.game_stage = 0
    return 'New season created!'
  end
end
