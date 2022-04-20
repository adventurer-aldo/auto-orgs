class Integer
    def player?
        return Player.exists?(user_id: self)
    end
end