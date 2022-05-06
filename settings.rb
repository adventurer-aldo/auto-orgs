class Sunny
    # PLAYER STATUS
    ALIVE = ['In','Immune','Idoled']
    DEAD = ['Out','Jury']

    # USERGROUPS/ROLES IDs
    HOSTS = [867100839654719498]
    EVERYONE = 963136641969569852
    IMMUNITY = 967156678728491058
    CASTAWAY = 964564440685101076
    JURY = 965717073454043268
    PREJURY = 965717099202904064
    SPECTATOR = 963454509269532752
    TRUSTED_SPECTATOR = 963454772189470720
    TRIBAL_PING = 965589333690179618
    ANNOUNCEMENTS_PING = 965589323049209887
    CHALLENGES_PING = 965589338807226408

    # OVERWRITES SETTINGS FOR CHANNELS
    DENY_EVERY_SPECTATE = Discordrb::Overwrite.new(EVERYONE, deny: 3072)
    EVERY_SPECTATE = Discordrb::Overwrite.new(EVERYONE, allow: 1088, deny: 2048)
    TRUE_SPECTATE = Discordrb::Overwrite.new(963454772189470720, type: 'role', allow: 1088, deny: 2048)
    JURY_SPECTATE = Discordrb::Overwrite.new(965717073454043268, type: 'role', allow: 1088, deny: 2048)
    PREJURY_SPECTATE = Discordrb::Overwrite.new(965717099202904064, type: 'role', allow: 1088, deny: 2048)

    # SERVER_STUFF
    USER_JOIN_CHANNEL = 963456028517757008
    USER_LEAVE_CHANNEL = 963456028517757008
    SERVER_ID = 963136641969569852

    PLAYING_SPLITTER = 968584931456458852
    PRE_JURY_SPLITTER = 968582054931480577
    JURY_SPLITTER = 968582138955976704

    # PARENT CATEGORIES IDs
    ALLIANCES = 966772850348404816
    COUNCILS = 965726451309641829
    FTC = 967058944365322240
    CHALLENGES = 965726505017671700
    TRIBES = 965620874453590056
    CONFESSIONALS = 965539764369518622
    ARCHIVE = 965563736372940880
    
    # TRIBAL
    COUNTING = %W(First Second Third Fourth Fifth Sixth Seventh Eigthth Ninth Tenth 
    Eleventh Twelfth Thirteenth Fourteenth Fifteenth Sixteenth Seventeeth Eighteenth Nineteenth Twentieth 
    Twenty-First Twenty-Second Twenty-Third Twenty-Fourth)
    
    
    DEFINED_FUNCTIONS = %w[
        idol
        idol_nullifier
        steal_vote
        block_vote
        extra_vote
        swap_idol
    ]

    # MISC
    CONFIRMATIONS = ['yes', 'yeah', 'yeh', 'yuh', 'yup', 'y','ye','heck yeah','yep','yessir','indeed','yessey','yess']
    PARCHMENT = 'https://i.imgflip.com/45drpi.png'
end