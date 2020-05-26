@discord_object struct DiscordChannel
    id::Snowflake
    type::ChannelType.ChannelTypeEnum
    guild_id::Snowflake
    position::Int
    permission_overwrites::Vector{Overwrite}
    name::String
    topic::String
    nsfw::Bool
    last_message_id::Snowflake
    bitrate::Int
    user_limit::Int
    rate_limit_per_user::Int
    recipients::Vector{User}
    icon::String
    owner_id::Snowflake
    application_id::Snowflake
    parent_id::Snowflake
    last_pin_timestamp::Union{String, DateTime}
end
