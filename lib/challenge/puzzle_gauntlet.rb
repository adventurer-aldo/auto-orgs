class Sunny
  PUZZLES = ['https://www.jigsawplanet.com/?rc=play&pid=1e8376c586dc', 'https://www.jigsawplanet.com/?rc=play&pid=1610911652d4', 'https://www.jigsawplanet.com/?rc=play&pid=3674208c81e1']

  BOT.command :show_scores do |event|
    html_to_image(%Q(<style>
    .orange-table td, .orange-table th {
      padding: 0.25rem; /* Smaller cells */
      background-color: #ffa726; /* Base orange */
      color: white;
    }
    .orange-table .score {
      background-color: #ffcc80; /* Lighter orange */
      color: black;
    }
  </style>
</head>
<body>
    <table class="table-primary table-sm orange-table text-center">
      <thead>
        <tr>
          <th>Player</th>
          <th>Score</th>
        </tr>
      </thead>
      <tbody>
      #{Individual.all.map { |individual| %Q(<tr>
          <td>#{individual.player.name}</td>
          <td class="score">#{individual.end_time ? individual.end_time - individual.start_time : ''}</td>
        </tr>)}.join('')}
      </tbody>
    </table>))
  end

  BOT.command :prepare_stuff do |event|
    break unless event.user.id.host?

    Player.where(status: ALIVE).each { |player| player.individuals.create(stage: 0, challenge_id: 0) }
  end

  BOT.command :gauntlet do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season: Setting.last.season)

    break unless event.channel.id == player.submissions
    individual = player.individuals.first

    break unless individual.stage == 0
    individual.update(start_time: Time.now.to_i, stage: 1)
    event.respond("Solve the puzzle, then send a screenshot of the completed piece! Afterwards, **write a command with the words within the completed image.**\n#{PUZZLES[0]}")
  end

  BOT.command :friendly_orca do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season: Setting.last.season)

    break unless event.channel.id == player.submissions
    individual = player.individuals.first

    break unless individual.stage == 1
    individual.update(stage: 2)
    event.respond("Part 2: Solve the puzzle, then send a screenshot of the completed piece! Afterwards, **write a command with the words within the completed image.**\n#{PUZZLES[1]}")
  end

  BOT.command :stealthy_snake do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season: Setting.last.season)

    break unless event.channel.id == player.submissions
    individual = player.individuals.first

    break unless individual.stage == 2
    individual.update(stage: 3)
    event.respond("Part 3: Solve the puzzle, then send a screenshot of the completed piece! Afterwards, **write a command with the words within the completed image.**\n#{PUZZLES[2]}")
  end

  BOT.command :proud_falcon do |event|
    break unless event.user.id.player?

    player = Player.find_by(user_id: event.user.id, season: Setting.last.season)

    break unless event.channel.id == player.submissions
    individual = player.individuals.first

    break unless individual.stage == 3

    time = Time.now.to_i
    individual.update(end_time: time, stage: 4)

    event.respond("You finished the gauntlet with **#{time - individual.start_time} seconds!**\nThat is, assuming you did send your screenshots before each new command.")
  end
end