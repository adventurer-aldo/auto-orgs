class Sunny
  def self.bootlist_pick_cell(pick, escape_html)
    player = pick&.player
    return '<td class="pick empty"></td>' unless player

    matched = player.rank.to_i == pick.rank.to_i if player.rank
    missed = player.rank && !matched
    status_class = matched ? ' hit' : missed ? ' miss' : ''
    actual = player.rank ? " - #{ordinal(player.rank)}" : ''

    %Q(
      <td class="pick#{status_class}">
        <div class="pick-wrap">
          #{draft_castaway_avatar(player)}
          <span>#{escape_html.call(player.name)}#{actual}</span>
        </div>
      </td>)
  end

  def self.get_bootlist_image
    escape_html = ->(text) { text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;') }
    bootlists = SpectatorGame::Bootlist.where(season_id: Setting.season_id).includes(:player).to_a
    grouped_bootlists = bootlists.group_by(&:user_id)
    scores = SpectatorGame::Bootlist.user_scores.index_by(&:user_id)
    max_slots = [bootlists.map(&:rank).compact.max.to_i, 1].max

    headers = (1..max_slots).map { |slot| "<th>#{ordinal(slot)}</th>" }.join
    rows = grouped_bootlists.sort_by { |user_id, _picks| scores[user_id]&.score || 0 }.map do |user_id, picks|
      spectator = draft_spectator_name(user_id)
      picks_by_rank = picks.index_by(&:rank)

      %Q(
        <tr>
          <td class="spectator">#{escape_html.call(spectator)}</td>
          #{(1..max_slots).map { |rank| bootlist_pick_cell(picks_by_rank[rank], escape_html) }.join}
          <td class="score">#{scores[user_id]&.score || 0}</td>
        </tr>)
    end.join

    base = %Q(
      <main class="bootlist-page">
        <section class="title-block">
          <p class="title-dot">!.</p>
          <h1>Alvivor Bootlist</h1>
        </section>

        <section class="table-card">
          <table>
            <thead>
              <tr>
                <th>Spectator</th>
                #{headers}
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
          color: #3f453e;
          font-family: Georgia, "Times New Roman", serif;
          margin: 0;
        }

        .bootlist-page {
          background: #fbfaf6;
          padding: 54px 42px 42px;
          width: max-content;
        }

        .title-block {
          margin: 0 0 26px;
          padding-top: 30px;
          text-align: center;
        }

        .title-dot {
          color: #fbfaf6;
          display: block;
          font-size: 1px;
          line-height: 1;
        }

        .title-block h1 {
          color: #46523d;
          font-size: 52px;
          font-weight: 500;
          line-height: 1;
          margin: 0;
        }

        .table-card {
          background: white;
          border: 1px solid #dedfd4;
          border-radius: 14px;
          box-shadow: 0 10px 30px rgba(0, 0, 0, 0.08);
          overflow: hidden;
        }

        table {
          border-collapse: separate !important;
          border-spacing: 0 !important;
          min-width: 980px;
          table-layout: auto !important;
          width: 100% !important;
        }

        thead {
          background: #e7e8dd;
        }

        thead th {
          border-bottom: 2px solid #d0d2c6;
          color: #46523d;
          font-size: 13px;
          letter-spacing: 0.08em;
          padding: 16px !important;
          text-align: center;
          text-transform: uppercase;
          white-space: nowrap;
        }

        tbody td {
          border-bottom: 1px solid #dedfd4;
          border-right: 1px solid #dedfd4;
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
          color: #46523d;
          font-size: 20px;
          min-width: 170px;
        }

        .pick {
          color: #5e665b;
          font-style: italic;
          min-width: 210px;
        }

        .score {
          color: #46523d;
          font-size: 20px;
          font-weight: 700;
          min-width: 72px;
        }

        .empty {
          background: #fbfaf6;
        }

        .pick-wrap {
          align-items: center;
          display: inline-flex;
          gap: 10px;
          justify-content: center;
        }

        .castaway-avatar {
          border: 2px solid #dedfd4;
          border-radius: 50%;
          height: 38px;
          object-fit: cover;
          width: 38px;
        }

        .hit {
          background: #e4ebe1;
          color: #2f563f;
          font-weight: 600;
        }

        .miss {
          background: #f4e9e3;
          color: #8f4a42;
        }
      </style>)
    html_to_image(base)
  end

  BOT.command :bootlist do |event|
    event.channel.send_file(Sunny.get_bootlist_image, filename: 'Bootlist.png')
  end
end
