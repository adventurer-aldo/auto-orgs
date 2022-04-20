class Sunny
    # PLAYER STATUS
    ALIVE = ['In','Immune','Idoled']
    DEAD = ['Out','Jury']

    # USERGROUPS IDs
    HOSTS = [822539645417422968,867100839654719498]
    EVERYONE = 963136641969569852

    # OVERWRITES SETTINGS FOR CHANNELS
    DENY_EVERY = Discordrb::Overwrite.new(EVERYONE, deny: 3072)
    TRUE_SPECTATE = Discordrb::Overwrite.new(963454772189470720, type: 'role', allow: 1088, deny: 2048)

    # SERVER_STUFF
    USER_JOIN_CHANNEL = 963456028517757008
    USER_LEAVE_CHANNEL = 963456028517757008
    SERVER_ID = 963136641969569852

    # PARENT CATEGORIES IDs
    COUNCILS = 965726451309641829
    CHALLENGES = 965726505017671700
    TRIBES = 965620874453590056
    CONFESSIONALS = 965539764369518622
    ARCHIVE = 965563736372940880
    
end