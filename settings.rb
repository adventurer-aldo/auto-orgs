class Sunny
    # PLAYER STATUS
    ALIVE = ['In','Immune','Idoled']
    DEAD = ['Out','Jury']

    # USERGROUPS IDs
    HOSTS = [822539645417422968,867100839654719498]
    EVERYONE = 963136641969569852

    # OVERWRITES SETTINGS FOR CHANNELS
    DENY_EVERY = Discordrb::Overwrite.new(EVERYONE, deny: 3072)
    EVERY_SPECTATE = Discordrb::Overwrite.new(EVERYONE, allow: 1088, deny: 2048)
    TRUE_SPECTATE = Discordrb::Overwrite.new(963454772189470720, type: 'role', allow: 1088, deny: 2048)
    JURY_SPECTATE = Discordrb::Overwrite.new(965717073454043268, type: 'role', allow: 1088, deny: 2048)
    PREJURY_SPECTATE = Discordrb::Overwrite.new(965717099202904064, type: 'role', allow: 1088, deny: 2048)

    # SERVER_STUFF
    USER_JOIN_CHANNEL = 963456028517757008
    USER_LEAVE_CHANNEL = 963456028517757008
    SERVER_ID = 963136641969569852

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
end