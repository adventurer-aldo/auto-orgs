class Sunny

    BOT.command :vote do |event, *args|
        # Need a vote command. Players can only be in one tribal council at a time.
        # ===========================================================================================
        # Vote should only be available if there's a vote with the player's id,
        # while checking for a council that is in stage 0 [Before 12h, can swap immunity or SA] or
        # stage 1 [After 12h, can't swap immunity or use safety advantage]
        # ===========================================================================================
        # If there's a council that meets those two conditions, plus the player has a vote ID that
        # matches, you can vote.
        # ===========================================================================================
        # First check if the player has enough votes. If you have 0, just...deny it.
        # If you have more than one vote, you HAVE to use either 1 or 2 as the first arg.
        # ===========================================================================================
        # Further optional condition: 
        # Use player name for identification for vote. If there's more than one player that matches a 
        # name, you'll have to use the ID.
        # If you fail even at that, well, just don't vote.
        # ===========================================================================================
        # Once votes are TOTAL_ALLOWED_VOTES == SUBMITTED VOTES, then enter Lock phase.
        # Once you lock, the Bot will make tribal council by itself.
        # It does not mean you can't change votes anymore. It merely means it will start early, unless
        # you need to rethink of something.

        player = Player.find_by(user_id: event.user.id, season: Setting.last.season)
        vote = Vote.where(player: player.id)
        council = Council.where(id: vote.council, stage: [0,1])
        if vote.exists? && council.exists?
            vote = Vote.where(council: council.id).and(vote)
            allowed_votes = vote.allowed
            if allowed_votes <= 0
                event.respond("You do not have any votes!")    
            else
                voted = nil
                enemies = Player.find_by(season: Setting.last.season)
                event.channel.send_embed do |embed|
                end
                event.message.await!(timeout: 40) do |await|

                end
                if voted == nil
                    "No vote was submitted..."
                else

                end
            end
        end
    end

end