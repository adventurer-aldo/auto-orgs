class Integer
  def player?
    Player.exists?(user_id: self, season: Setting.last.season)
  end

  def host?
    HOSTS.include? event.user.id
  end
end
