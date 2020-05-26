@discord_object struct ChannelMention
    id::Snowflake
    guild_id::Snowflake
    type::ChannelType.ChannelTypeEnum
    name::String
end
