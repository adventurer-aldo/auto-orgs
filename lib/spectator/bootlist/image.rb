class Sunny
  def self.actual_boot_order_player_ids
    eliminated_events = Event.where('summary = ? OR summary LIKE ?', 'eliminated', 'eliminated:%')
                             .where.not(player_id: nil)

    if Event.column_names.include?('episode_id')
      eliminated_events = eliminated_events.joins('LEFT JOIN episodes ON episodes.id = events.episode_id')
                                           .order('episodes.number ASC NULLS LAST, events.id ASC')
    else
      eliminated_events = eliminated_events.order(:id)
    end

    eliminated_events.filter_map do |event_row|
      player = Player.find_by(id: event_row.player_id, season_id: Setting.season_id)
      player&.id
    end.uniq
  end

  def self.bootlist_pick_cell(player_id, actual_player_id, escape_html)
    player = Player.find_by(id: player_id, season_id: Setting.season_id)
    return '<td class="pick empty"></td>' unless player

    matched = actual_player_id == player.id
    missed = actual_player_id && actual_player_id != player.id
    status_class = matched ? ' hit' : missed ? ' miss' : ''

    %Q(
      <td class="pick#{status_class}">
        <div class="pick-wrap">
          #{draft_castaway_avatar(player)}
          <span>#{escape_html.call(player.name)}</span>
        </div>
      </td>)
  end

  def self.get_bootlist_image
    escape_html = ->(text) { text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;') }
    bootlists = SpectatorGame::Bootlist.where(season_id: Setting.season_id).sort_by { |bootlist| bootlist.score || 0 }
    actual_order = actual_boot_order_player_ids
    max_slots = [bootlists.map { |bootlist| bootlist.values.size }.max.to_i, actual_order.size, 1].max

    headers = (1..max_slots).map { |slot| "<th>#{ordinal(slot)}</th>" }.join
    rows = bootlists.map do |bootlist|
      spectator = draft_spectator_name(bootlist.user_id)

      %Q(
        <tr>
          <td class="spectator">#{escape_html.call(spectator)}</td>
          #{(0...max_slots).map { |index| bootlist_pick_cell(bootlist.values[index], actual_order[index], escape_html) }.join}
          <td class="score">#{bootlist.score}</td>
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
