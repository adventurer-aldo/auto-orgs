# frozen_string_literal: true

class Sunny
  # PLAYER STATUS
  ALIVE = %w[In Immune Idoled]
  DEAD = %w[Out Jury]

  # USERGROUPS/ROLES IDs
  HOSTS = [867100839654719498]
  EVERYONE = 1113165917870895256
  IMMUNITY = 1113175246971863102
  CASTAWAY = 1113175244774060123
  JURY = 1113175243020828702
  PREJURY = 1113175241011765329
  SPECTATOR = 1113168262461673532
  TRUSTED_SPECTATOR = 1113175228290441386
  TRIBAL_PING = 1113175235051663410
  ANNOUNCEMENTS_PING = 1113175237073322066
  CHALLENGES_PING = 1113175238998503605

  # OVERWRITES SETTINGS FOR CHANNELS
  DENY_EVERY_SPECTATE = Discordrb::Overwrite.new(EVERYONE, deny: 3072)
  EVERY_SPECTATE = Discordrb::Overwrite.new(EVERYONE, allow: 1088, deny: 2048)
  TRUE_SPECTATE = Discordrb::Overwrite.new(TRUSTED_SPECTATOR, type: 'role', allow: 1088, deny: 2048)
  JURY_SPECTATE = Discordrb::Overwrite.new(JURY, type: 'role', allow: 1088, deny: 2048)
  PREJURY_SPECTATE = Discordrb::Overwrite.new(PREJURY, type: 'role', allow: 1088, deny: 2048)

  # SERVER_STUFF
  USER_JOIN_CHANNEL = 1113165918470668390
  USER_LEAVE_CHANNEL = 1113165918470668390
  SERVER_ID = 1113165917870895256

  PLAYING_SPLITTER = 1124061420586291343
  PRE_JURY_SPLITTER = 1113176402884304946
  JURY_SPLITTER = 1113176442004570244

  # PARENT CATEGORIES IDs
  ALLIANCES = 1113176204741197914
  COUNCILS = 1113177022001324052
  FTC = 1113176972022005800
  CHALLENGES = 1113177058173005864
  TRIBES = 1113176868389146766
  CONFESSIONALS = 1113176156611555369
  ARCHIVE = 1113176920004247713

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
  CONFIRMATIONS = ['yes', 'yea', 'yeah', 'yeh', 'yuh', 'yup', 'y','ye','heck yeah','yep','yessir','indeed','yessey','yess']
  PARCHMENT = 'https://i.ibb.co/HdkxRNz/Parchment.png'

  def self.hosts
    return HOSTS
  end
end