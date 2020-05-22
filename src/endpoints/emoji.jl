get_guild_emojis(c, guild) =
    api_call(c, :GET, "/guilds/$guild/emojis", Vector{Emoji})
get_guild_emoji(c, guild, emoji) =
    api_call(c, :GET, "/guilds/$guild/emojis/$emoji", Emoji)
create_guild_emoji(c, guild; kwargs...) =
    api_call(c, :POST, "/guilds/$guild/emojis", Emoji; kwargs...)
update_guild_emoji(c, guild; kwargs...) =
    api_call(c, :PATCH, "/guilds/$guild/emojis", Emoji; kwargs...)
delete_guild_emoji(c, guild, emoji) =
    api_call(c, :DELETE, "/guilds/$guild/emojis/$emoji")
