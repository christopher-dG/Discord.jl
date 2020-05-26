@discord_object struct Presence
    user::User
    roles::Vector{Snowflake}
    game::Activity
    guild_id::Snowflake
    status::String
    activities::Vector{Activity}
    client_status::ClientStatus
    premium_since::Union{String, DateTime}
    nick::String
end
