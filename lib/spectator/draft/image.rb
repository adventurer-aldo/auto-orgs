class Sunny
  def self.draft_castaway_avatar(player)
    return '' unless player && Shrine.storages[:store].exists?(player.image_storage_id)

    %Q(<img class="castaway-avatar" src="#{player.image_url}">)
  rescue StandardError
    ''
  end

  def self.draft_pick_cell(player, css_class, escape_html)
    return %Q(<td class="#{css_class}"></td>) unless player

    eliminated = !ALIVE.include?(player.status)
    status_class = eliminated ? ' eliminated' : ''
    placement = eliminated && player.rank ? " - #{ordinal(player.rank)}" : ''
    %Q(
      <td class="#{css_class}#{status_class}">
        <div class="pick-wrap">
          #{draft_castaway_avatar(player)}
          <span>#{escape_html.call(player.name)}#{placement}</span>
        </div>
      </td>)
  end

  def self.ordinal(number)
    return "#{number}th" if (11..13).cover?(number % 100)

    suffix = case number % 10
             when 1 then 'st'
             when 2 then 'nd'
             when 3 then 'rd'
             else 'th'
             end
    "#{number}#{suffix}"
  end

  def self.draft_spectator_name(user_id)
    user = BOT.user(user_id)
    user.on(Setting.server_id)&.display_name || user.username
  rescue StandardError
    'Deleted User'
  end

  def self.get_draft_image
    escape_html = ->(text) { text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;') }
    drafts = SpectatorGame::Draft.where(season_id: Setting.season_id).sort_by { |draft| draft.score || 0 }
                                 .select { |draft| !draft.winner_pick.nil? && !draft.pick_1.nil? && !draft.pick_2.nil? && !draft.pick_3.nil? }

    rows = drafts.map do |draft|
      winner = Player.find_by(id: draft.winner_pick)
      pick_1 = Player.find_by(id: draft.pick_1)
      pick_2 = Player.find_by(id: draft.pick_2)
      pick_3 = Player.find_by(id: draft.pick_3)
      spectator = draft_spectator_name(draft.user_id)
      all_picks_eliminated = [winner, pick_1, pick_2, pick_3].all? { |player| player && !ALIVE.include?(player.status) }

      %Q(
        <tr>
          <td class="spectator">#{escape_html.call(spectator)}</td>
          #{draft_pick_cell(winner, 'winner', escape_html)}
          #{draft_pick_cell(pick_1, 'pick', escape_html)}
          #{draft_pick_cell(pick_2, 'pick', escape_html)}
          #{draft_pick_cell(pick_3, 'pick', escape_html)}
          <td class="score#{all_picks_eliminated ? ' eliminated-score' : ''}">#{draft.score}</td>
        </tr>)
    end.join('')

    base = %Q(
      <main class="draft-page">
        <section class="title-block">
          <h1>Alvivor Draft</h1>
        </section>

        <section class="table-card">
          <table>
            <thead>
              <tr>
                <th>Spectator</th>
                <th>Winner Pick 👑</th>
                <th>Pick 1</th>
                <th>Pick 2</th>
                <th>Pick 3</th>
                <th>Score</th>
              </tr>
            </thead>
            <tbody>
              #{rows}
            </tbody>
          </table>
        </section>
      </main>

      <style>
        body {
          background: #fbfaf6 !important;
          color: #33483d;
          font-family: Georgia, "Times New Roman", serif;
          margin: 0;
        }

        .draft-page {
          background: #fbfaf6;
          padding: 54px 42px 42px;
          width: max-content;
        }

        .title-block {
          margin: 0 0 26px;
          padding-top: 30px;
          text-align: center;
        }

        .title-block h1 {
          color: #2f563f;
          font-size: 52px;
          font-weight: 500;
          line-height: 1;
          margin: 0;
        }

        .table-card {
          background: white;
          border: 1px solid #dfe6dc;
          border-radius: 14px;
          box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
          overflow: hidden;
        }

        table {
          border-collapse: separate !important;
          border-spacing: 0 !important;
          min-width: 1040px;
          table-layout: auto !important;
          width: 100% !important;
        }

        thead {
          background: #e4ebe1;
        }

        thead th {
          border-bottom: 2px solid #cbd7c8;
          color: #385246;
          font-size: 13px;
          letter-spacing: 0.08em;
          padding: 16px !important;
          text-align: center;
          text-transform: uppercase;
          white-space: nowrap;
        }

        tbody td {
          border-bottom: 1px solid #dfe6dc;
          border-right: 1px solid #dfe6dc;
          padding: 16px !important;
          text-align: center;
          vertical-align: middle;
          white-space: nowrap;
        }

        tbody td:last-child {
          border-right: none;
        }

        tbody tr:last-child td {
          border-bottom: none;
        }

        .spectator {
          color: #2f563f;
          font-size: 20px;
          min-width: 170px;
          text-align: center;
        }

        .winner {
          color: #b78149;
          font-weight: 600;
        }

        .pick {
          color: #5c6f63;
          font-style: italic;
        }

        .score {
          color: #2f563f;
          font-size: 20px;
          font-weight: 700;
          min-width: 72px;
        }

        .pick-wrap {
          align-items: center;
          display: inline-flex;
          gap: 10px;
          justify-content: center;
        }

        .castaway-avatar {
          border: 2px solid #dfe6dc;
          border-radius: 50%;
          height: 38px;
          object-fit: cover;
          width: 38px;
        }

        .eliminated {
          background: #f4e9e3;
          color: #8f4a42;
        }

        .eliminated-score {
          background: #f4e9e3;
          color: #8f4a42;
        }
      </style>)
    html_to_image(base)
  end

  BOT.command :draft do |event|
    event.channel.send_file(Sunny.get_draft_image, filename: 'Draft.png')
  end
end
