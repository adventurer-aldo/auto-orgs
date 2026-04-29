class Integer
  def player?
    Player.exists?(user_id: self, season_id: Setting.season_id)
  end

  def host?
    Setting.hosts_ids.include? self
  end
end
