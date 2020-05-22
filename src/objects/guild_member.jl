@discord_object struct GuildMember
    user::User
    nick::String
    roles::Vector{Snowflake}
    joined_at::Union{String, DateTime}
    premium_since::Union{String, DateTime}
    deaf::Bool
    mute::Bool
end
