create_guild(c; kwargs...) =
    api_call(c, :POST, "/guilds", Guild; kwargs...)
get_guild(c, guild; kwargs...) =
    api_call(c, :GET, "/guilds/$guild", Guild; kwargs...)
get_guild_preview(c, guild; kwargs...) =
    api_call(c, :GET, "/guilds/$guild/preview", Guild)
update_guild(c, guild; kwargs...) =
    api_call(c, :PATCH, "/guilds/$guild", Guild; kwargs...)
delete_guild(c, guild) =
    api_call(c, :DELETE, "/guilds/$guild")
get_guild_channels(c, guild) =
    api_call(c, :GET, "/guilds/$guild/channels", Vector{DiscordChannel})
create_guild_channel(c, guild; kwargs...) =
    api_call(c, :POST, "/guilds/$guild/channels", Guild; kwargs...)
# TODO: How should we pass an array as the body?
# update_guild_channel_positions(c, guild; kwargs...) =
#     api_call(c, :PATCH, "/guilds/$guild/channels", TODO)
get_guild_member(c, guild, user) =
    api_call(c, :GET, "/guilds/$guild/members/$user", GuildMember)
get_guild_members(c, guild; kwargs...) =
    api_call(c, :GET, "/guilds/$guild/members", Vector{GuildMember}; kwargs...)
create_guild_member(c, guild, user; kwargs...) =
    api_call(c, :PUT, "/guilds/$guild/members/$user", GuildMember; kwargs...)
update_guild_member(c, guild, user; kwargs...) =
    api_call(c, :PATCH, "/guilds/$guild/members/$user"; kwargs...)
modify_user_nick(c, guild; kwargs...) =
    api_call(c, :PATCH, "/guilds/$guild/members/@me/nick", String; kwargs...)
create_guild_member_role(c, guild, user, role) =
    api_call(c, :PUT, "/guilds/$guild/users/$user/roles/$role")
delete_guild_member_role(c, guild, user, role) =
    api_call(c, :DELETE, "/guilds/$guild/users/$user/roles/$role")
delete_guild_member(c, guild, user) =
    api_call(c, :DELETE, "/guilds/$guild/users/$user")
get_guild_bans(c, guild) =
    api_call(c, :GET, "/guilds/$guild/bans", Vector{Guild})
get_guild_ban(c, guild, user) =
    api_call(c, :GET, "/guilds/$guild/bans/$user", Ban)
create_guild_ban(c, guild, user; kwargs...) =
    api_call(c, :PUT, "/guilds/$guild/bans/$user"; kwargs...)
delete_guild_ban(c, guild, user) =
    api_call(c, :DELETE, "/guilds/$guild/bans/$user")
get_guild_roles(c, guild) =
    api_call(c, :GET, "/guilds/$guild/roles", Vector{Role})
create_guild_role(c, guild; kwargs...) =
    api_call(c, :POST, "/guilds/$guild/roles", Role; kwargs...)
# TODO: How should we pass an array as the body?
# update_guild_role_positions(c, guild; kwargs...) =
#     api_call(c, :PATCH, "/guilds/$guild/roles", Vector{Role}, TODO)
update_guild_role(c, guild, role; kwargs...) =
    api_call(c, :PATCH, "/guilds/$guild/roles/$role", Role; kwargs...)
delete_guild_role(c, guild, role) =
    api_call(c, :DELETE, "/guilds/$guild/roles/$role")
get_guild_prune_count(c, guild; kwargs...) =
    api_call(c, :GET, "/guilds/$guild/prune", PruneCount; kwargs...)
create_guild_prunt(c, guild; kwargs...) =
    api_call(c, :POST, "/guilds/$guild/prune", PruneCount; kwargs...)
get_guild_voice_regions(c, guild) =
    api_call(c, :GET, "/guilds/$guild/regions", Vector{VoiceRegion})
get_guild_invites(c, guild) =
    api_call(c, :GET, "/guilds/$guild/invites", Vector{Invite})
get_guild_integrations(c, guild) =
    api_call(c, :GET, "/guilds/$guild/integrations", Vector{Integration})
create_guild_integration(c, guild; kwargs...) =
    api_call(c, :POST, "/guilds/$guild/integrations"; kwargs...)
update_guild_integration(c, guild, integration; kwargs...) =
    api_call(c, :PATCH, "/guilds/$guild/integrations/$integration"; kwargs...)
delete_guild_integration(c, guild, integration) =
    api_call(c, :PATCH, "/guilds/$guild/integrations/$integration")
sync_guild_integration(c, guild, integration) =
    api_call(c, :POST, "/guilds/$guild/integrations/$integration/sync")
get_guild_widget(c, guild) =
    api_call(c, :GET, "/guilds/$guild/widget", GuildWidget)
update_guild_widget(c, guild; kwargs...) =
    api_call(c, :PATCH, "/guilds/$guild/widget", GuildWidget; kwargs...)
get_guild_vanity_url(c, guild) =
    api_call(c, :GET, "/guilds/$guild/vanity-url", Invite)
get_guild_widget_image(c, guild) =
    api_call(c, :GET, "/guilds/$guild/widget.png", String)
