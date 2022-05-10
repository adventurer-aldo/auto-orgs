class Integer
    def player?
        return Player.exists?(user_id: self, season: Setting.last.season)
    end
    
    def host?
        return HOSTS.include? event.user.id
    end
end
