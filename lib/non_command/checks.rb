class Integer
  def player?
    Player.exists?(user_id: self, season: Setting.last.season)
  end

  def host?
    Sunny.hosts.include? self
  end
end
