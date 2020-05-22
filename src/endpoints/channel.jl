get_channel(c, channel) =
    api_call(c, :GET, "/channels/$channel", DiscordChannel)
update_channel(c, channel; kwargs...) =
    api_call(c, :PATCH, "/channels/$channel", DiscordChannel; kwargs...)
delete_channel(c, channel) =
    api_call(c, :DELETE, "/channels/$channel", DiscordChannel)
get_channel_messages(c, channel; kwargs...) =
    api_call(c, :GET, "/channels/$channel/messages", Vector{Message}; kwargs...)
get_channel_message(c, channel, message) =
    api_call(c, :GET, "/channels/$channel/messages/$message", Message)
create_message(c, channel; kwargs...) =
    api_call(c, :POST, "/channels/$channel/messages", Message; kwargs...)
create_reaction(c, channel, message, emoji) =
    api_call(c, :PUT, "/channels/$channel/messages/$message/reactions/$(escapeuri(emoji))/@me")
delete_reaction(c, channel, message, emoji, user="@me") =
    api_call(c, :DELETE, "/channels/$channel/messages/$message/reactions/$(escapeuri(emoji))/$user")
get_reactions(c, channel, message, emoji; kwargs...) =
    api_call(c, :GET, "/channels/$channel/messages/$message/reactions/$(escapeuri(emoji))", Vector{User}; kwargs...)
function delete_all_reactions(c, channel, message, emoji=nothing)
    url = "/channels/$channel/messages/$message/reactions"
    if emoji !== nothing
        url *= "/$(escapeuri(emoji))"
    end
    return api_call(c, :DELETE, url)
end
update_message(c, channel, message; kwargs...) =
    api_call(c, :PATCH, "/channels/$channel/messages/$message", Message; kwargs...)
delete_message(c, channel, message) =
    api_call(c, :DELETE, "/channels/$channel/messages/$message")
delete_messages(c, channel; kwargs...) =
    api_call(c, :POST, "/channels/$channel/messages/bulk-delete"; kwargs...)
update_channel_permissions(c, channel, overwrite; kwargs...) =
    api_call(c, :PUT, "/channels/$channel/permissions/$overwrite"; kwargs...)
get_channel_invites(c, channel; kwargs...) =
    api_call(c, :GET, "/channels/$channel/invites", Vector{Invite}; kwargs...)
create_channel_invite(c, channel; kwargs...) =
    api_call(c, :POST, "/channels/$channel/invites", Invite; kwargs...)
delete_channel_permission(c, channel, overwrite) =
    api_call(c, :DELETE, "/channels/$channel/permissions/$overwrite")
create_typing_indicator(c, channel) =
    api_call(c, :POST, "/channels/$channel/typing")
get_pinned_messages(c, channel) =
    api_call(c, :GET, "/channels/$channel/pins", Vector{Message})
create_pinned_channel_message(c, channel, message) =
    api_call(c, :PUT, "/channels/$channel/pins/$message")
delete_pinned_channel_message(c, channel, message) =
    api_call(c, :DELETE, "/channels/$channel/pins/$message")
create_group_dm_recipient(c, channel, user; kwargs...) =
    api_call(c, :PUT, "/channels/$channel/recipients/$user"; kwargs...)
delete_group_dm_recipient(c, channel, user) =
    api_call(c, :DELETE, "/channels/$channel/recipients/$user")
