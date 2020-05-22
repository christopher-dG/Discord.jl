get_channel_webhooks(c, channel) =
    api_call(c, :GET, "/channels/$channel/webhooks", Vector{Webhook})
get_guild_webhooks(c, guild) =
    api_call(c, :GET, "/guilds/$guild/webhooks", Vector{Webhook})
function get_webhook(c, webhook, token=nothing)
    url = "/webhooks/$webhook"
    if token !== nothing
        url *= "/$token"
    end
    return api_call(c, :GET, url, Webhook)
end
function update_webhook(c, webhook, token=nothing; kwargs...)
    url = "/webhooks/$webhook"
    if token !== nothing
        url *= "/$token"
    end
    return api_call(c, :PATCH, url, Webhook; kwargs...)
end
function delete_webhook(c, webhook, token=nothing; kwargs...)
    url = "/webhooks/$webhook"
    if token !== nothing
        url *= "/$token"
    end
    return api_call(c, :DELETE, url, Webhook; kwargs...)
end
# TODO: Need to handle some stuff here.
# execute_webhook(c, webhook, token; kwargs...) =
#     api_call(c, :POST, "/webhooks/$webhook/$token", TODO)
# execute_webhook_github_(c, webhook, token; kwargs...) =
#     api_call(c, :POST, "/webhooks/$webhook/$token/github", TODO)
# execute_webhook_slack(c, webhook, token; kwargs...) =
#     api_call(c, :POST, "/webhooks/$webhook/$token/slack", TODO)
