@discord_enum UserPremiumType begin
    NO_PREMIUM_TYPE = 0
    NITRO_CLASSIC = 1
    NITRO = 2
end

@discord_enum IntegrationExpireBehavior begin
    REMOVE_ROLE = 0
    KICK = 1
end

@discord_enum ConnectionVisibility begin
    VISIBILITY_NONE = 0
    VISIBILITY_EVERYONE = 1
end

@discord_enum ChannelType begin
    GUILD_TEXT = 0
    DM = 1
    GUILD_VOICE = 2
    GROUP_DM = 3
    GUILD_CATEGORY = 4
    GUILD_NEWS = 5
    GUILD_STORE = 6
end

@discord_enum MessageType begin
    MESSAGE_TYPE_DEFAULT = 0
    RECIPIENT_ADD = 1
    RECIPIENT_REMOVE = 2
    CALL = 3
    CHANNEL_NAME_CHANGE = 4
    CHANNEL_ICON_CHANGE = 5
    CHANNEL_PINNED_MESSAGE = 6
    GUILD_MEMBER_JOIN = 7
    USER_PREMIUM_GUILD_SUBSCRIPTION = 8
    USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_1 = 9
    USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_2 = 10
    USER_PREMIUM_GUILD_SUBSCRIPTION_TIER_3 = 11
    CHANNEL_FOLLOW_ADD = 12
    GUILD_DISCOVERY_DISQUALIFIED = 14
    GUILD_DISCOVERY_REQUALIFIED = 15
end

@discord_enum MessageActivityType begin
    TYPE_JOIN = 1
    TYPE_SPECTATE = 2
    TYPE_LISTEN = 3
    TYPE_JOIN_REQUEST = 5
end

@discord_enum VerificationLevel begin
    VERIFICATION_LEVE_NONE = 0
    LOW = 1
    MEDIUM = 2
    HIGH = 3
    VERY_HIGH = 4
end

@discord_enum MessageNotificationsLevel begin
    ALL_MESSAGES = 0
    ONLY_MENTIONS = 1
end

@discord_enum ExplicitContentFilter begin
    EXPLICIT_CONTENT_FILTER_DISABLED = 0
    MEMBERS_WITHOUT_ROLES = 1
    ALL_MEMBERS = 2
end

@discord_enum MFALevel begin
    MFA_LEVEL_NONE = 0
    ELEVATED = 1
end

@discord_enum PremiumTier begin
    PREMIUM_TIER_NONE = 0
    TIER_1 = 1
    TIER_2 = 2
    TIER_3 = 3
end

@discord_enum ActivityType begin
    GAME = 0
    STREAMING = 1
    LISTENING = 2
    CUSTOM = 3
end

@discord_enum WebhookType begin
    INCOMING = 1
    CHANNEL_FOLLOWER = 2
end

@discord_enum AuditLogEvent begin
    GUILD_UPDATE = 1
    CHANNEL_CREATE = 10
    CHANNEL_UPDATE = 11
    CHANNEL_DELETE = 12
    CHANNEL_OVERWRITE_CREATE = 13
    CHANNEL_OVERWRITE_UPDATE = 14
    CHANNEL_OVERWRITE_DELETE = 15
    MEMBER_KICK = 20
    MEMBER_PRUNE = 21
    MEMBER_BAN_ADD = 22
    MEMBER_BAN_REMOVE = 23
    MEMBER_UPDATE = 24
    MEMBER_ROLE_UPDATE = 25
    MEMBER_MOVE = 26
    MEMBER_DISCONNECT = 27
    BOT_ADD = 28
    ROLE_CREATE = 30
    ROLE_UPDATE = 31
    ROLE_DELETE = 32
    INVITE_CREATE = 40
    INVITE_UPDATE = 41
    INVITE_DELETE = 42
    WEBHOOK_CREATE = 50
    WEBHOOK_UPDATE = 51
    WEBHOOK_DELETE = 52
    EMOJI_CREATE = 60
    EMOJI_UPDATE = 61
    EMOJI_DELETE = 62
    MESSAGE_DELETE = 72
    MESSAGE_BULK_DELETE = 73
    MESSAGE_PIN = 74
    MESSAGE_UNPIN = 75
    INTEGRATION_CREATE = 80
    INTEGRATION_UPDATE = 81
    INTEGRATION_DELETE = 82
end

@discord_enum TargetUserType begin
    STREAM = 1
end

@discord_enum UserFlags begin
    USER_FLAGS_NONE = 0
    DISCORD_EMPLOYEE = 1 << 0
    DISCORD_PARTNER = 1 << 1
    HYPESQUAD_EVENTS = 1 << 2
    BUG_HUNTER_1 = 1 << 3
    HOUSE_BRAVERY = 1 << 6
    HOUSE_BRILLIANCE = 1 << 7
    HOUSE_BALANCE = 1 << 8
    EARLY_SUPPORTER = 1 << 9
    TEAM_USER = 1 << 10
    SYSTEM = 1 << 12
    BUG_HUNTER_2 = 1 << 14
    VERIFIED_BOT = 1 << 16
    VERIFIED_BOT_DEVELOPER = 1 << 17
end

@discord_enum MessageFlags begin
    CROSSPOSTED = 1 << 0
    IS_CROSSPOST = 1 << 1
    SUPPRESS_EMBEDS = 1 << 2
    SOURCE_MESSAGE_DELETED = 1 << 3
    URGENT = 1 << 4
end

@discord_enum SystemChannelFlags begin
    SUPPRESS_JOIN_NOTIFICATIONS = 1 << 0
    SUPPRESS_PREMIUM_SUBSCRIPTIONS = 1 << 1
end

@discord_enum ActivityFlags begin
    INSTANCE = 1 << 0
    JOIN = 1 << 1
    SPECTATE = 1 << 2
    JOIN_REQUEST = 1 << 3
    SYNC = 1 << 4
    PLAY = 1 << 5
end
