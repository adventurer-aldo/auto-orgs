class Sunny
  def self.elimination_event_scope(player, episode_id)
    scope = Event.where(player_id: player.id)
                 .where('summary = ? OR summary LIKE ?', 'eliminated', 'eliminated:%')
    Event.column_names.include?('episode_id') ? scope.where(episode_id: episode_id) : scope
  end

  def self.eliminated_in_episode?(player, episode_id)
    player && elimination_event_scope(player, episode_id).exists?
  end

  def self.elimination_pick_cell(player, episode_id, escape_html)
    return '<td class="pick empty"></td>' unless player

    eliminated = eliminated_in_episode?(player, episode_id)
    status_class = eliminated ? ' eliminated' : ''

    %Q(
      <td class="pick#{status_class}">
        <div class="pick-wrap">
          #{draft_castaway_avatar(player)}
          <span>#{escape_html.call(player.name)}</span>
        </div>
      </td>)
  end

  def self.elimination_episode_label(episode)
    label = episode.number || episode.id
    "Episode #{label}"
  end

  def self.get_eliminator_image
    escape_html = ->(text) { text.to_s.gsub('&', '&amp;').gsub('<', '&lt;').gsub('>', '&gt;').gsub('"', '&quot;') }
    eliminations = SpectatorGame::Elimination.where(season_id: Setting.season_id)
    episode_ids = eliminations.where.not(episode_id: nil).pluck(:episode_id).uniq
    episodes = Episode.where(season_id: Setting.season_id, id: episode_ids).order(:number, :id).to_a
    episodes = [current_episode] if episodes.empty?

    rows = eliminations.group_by(&:user_id).map do |user_id, picks|
      picks_by_episode = picks.index_by(&:episode_id)
      spectator = draft_spectator_name(user_id)

      %Q(
        <tr>
          <td class="spectator">#{escape_html.call(spectator)}</td>
          #{episodes.map do |episode|
              pick = picks_by_episode[episode.id]
              player = Player.find_by(id: pick&.player_id)
              elimination_pick_cell(player, episode.id, escape_html)
            end.join}
        </tr>)
    end.join

    headers = episodes.map { |episode| "<th>#{escape_html.call(elimination_episode_label(episode))}</th>" }.join

    base = %Q(
      <main class="elimination-page">
        <section class="title-block">
          <p class="title-dot">!.</p>
          <h1>Alvivor Elimination</h1>
        </section>

        <section class="table-card">
          <table>
            <thead>
              <tr>
                <th>Spectator</th>
                #{headers}
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
          color: #513638;
          font-family: Georgia, "Times New Roman", serif;
          margin: 0;
        }

        .elimination-page {
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
          color: #7d1e24;
          font-size: 52px;
          font-weight: 500;
          line-height: 1;
          margin: 0;
        }

        .table-card {
          background: white;
          border: 1px solid #ead8d6;
          border-radius: 14px;
          box-shadow: 0 10px 30px rgba(88, 22, 29, 0.12);
          overflow: hidden;
        }

        table {
          border-collapse: separate !important;
          border-spacing: 0 !important;
          min-width: 780px;
          table-layout: auto !important;
          width: 100% !important;
        }

        thead {
          background: #f2dfdc;
        }

        thead th {
          border-bottom: 2px solid #dfc5c0;
          color: #6c3033;
          font-size: 13px;
          letter-spacing: 0.08em;
          padding: 16px !important;
          text-align: center;
          text-transform: uppercase;
          white-space: nowrap;
        }

        tbody td {
          border-bottom: 1px solid #ead8d6;
          border-right: 1px solid #ead8d6;
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
          color: #7d1e24;
          font-size: 20px;
          min-width: 170px;
        }

        .pick {
          color: #654647;
          font-style: italic;
          min-width: 210px;
        }

        .empty {
          background: #fcf8f6;
        }

        .pick-wrap {
          align-items: center;
          display: inline-flex;
          gap: 10px;
          justify-content: center;
        }

        .castaway-avatar {
          border: 2px solid #ead8d6;
          border-radius: 50%;
          height: 38px;
          object-fit: cover;
          width: 38px;
        }

        .eliminated {
          background: #8b1f28;
          color: #fff7f4;
          font-weight: 600;
        }

        .eliminated .castaway-avatar {
          border-color: #f4c9c3;
        }
      </style>)
    html_to_image(base)
  end

  BOT.command :eliminator do |event|
    event.channel.send_file(Sunny.get_eliminator_image, filename: 'eliminator.png')
  end
end
