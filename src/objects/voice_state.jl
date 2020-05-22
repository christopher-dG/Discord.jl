@discord_object struct VoiceState
    guild_id::Snowflake
    channel_id::Snowflake
    user_id::Snowflake
    member::GuildMember
    session_id::String
    deaf::Bool
    mute::Bool
    self_deaf::Bool
    self_mute::Bool
    self_stream::Bool
    suppress::Bool
end
