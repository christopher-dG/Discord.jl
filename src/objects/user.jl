@discord_object struct User
    id::Snowflake
    username::String
    discriminator::String
    avatar::String
    bot::Bool
    system::Bool
    mfa_enabled::Bool
    locale::String
    verified::Bool
    email::String
    flags::Int
    premium_type::UserPremiumType
    public_flags::Int
    # TODO: Add a PartialGuildMember struct or something?
    # https://discord.com/developers/docs/resources/channel#message-object-message-structure
end
