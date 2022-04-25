class Integer
    def player?
        return Player.exists?(user_id: self, season: Setting.last.season)
    end
end
