get_user(c, user="@me") =
    api_call(c, :GET, "/users/$user", User)
update_user(c; kwargs...) =
    api_call(c, :PATCH, "/users/@me", User; kwargs...)
get_user_guilds(c; kwargs...) =
    api_call(c, :GET, "/users/@me/guilds", Vector{Guild}; kwargs...)
leave_guild(c, guild) =
    api_call(c, :DELETE, "/users/@me/guilds/$guild")
get_user_dms(c) =
    api_call(c, :GET, "/users/@me/channels", Vector{DiscordChannel})
create_dm(c; kwargs...) =
    api_call(c, :POST, "/users/@me/channels", DiscordChannel; kwargs...)
create_group_dm(c; kwargs...) =
    api_call(c, :POST, "/users/@me/channels", DiscordChannel; kwargs...)
get_user_connections(c) =
    api_call(c, :GET, "/users/@me/connections", Vector{Connection})
