# A hack to make it easier to pass in an array payload.
struct ArrayBody{T}
    xs::T
end

JSON3.write(kw::Pairs{Symbol, ArrayBody{T}, Tuple{Symbol}, NamedTuple{(:array,), Tuple{ArrayBody{T}}}}) where T =
    JSON3.write(kw.data.array.xs)

function api_call(c, method, path, Into=Nothing, params=Dict();  kwargs...)
    headers = [
        "Authorization" => auth_header(c),
        "User-Agent" => USER_AGENT,
        "X-RateLimit-Precision" => "millisecond",
    ]

    body, query = if method in (:PATCH, :PUT, :POST)
        push!(headers, "Content-Type" => "application/json")
        (isempty(kwargs) ? "" : JSON3.write(kwargs)), params
    else
        "", kwargs
    end

    url = "$API_BASE/v$API_VERSION$path"
    if check_rate_limits(rate_limiter(c), path) === RATE_LIMIT_SENTINEL
        return RATE_LIMIT_SENTINEL
    end

    resp = request(method, url, headers, body; query=query, status_exception=false)
    if apply_rate_limits!(rate_limiter(c), resp) === RATE_LIMIT_SENTINEL
        return RATE_LIMIT_SENTINEL
    end

    if 200 <= resp.status < 300
        return parse_response(resp, Into)
    else
        throw(StatusError(resp.status, resp))
    end
end

parse_response(resp::Response, ::Type{Nothing}) = nothing
function parse_response(resp::Response, Into)
    return if resp.status == 204
        nothing
    elseif header(resp, "Content-Type") == "application/json"
        x = JSON3.read(resp.body, Into)
        fix_datetimes!(x)
        x
    else
        resp.body
    end
end

# I hate this.
parse_datetime(s) = DateTime(replace(s, "+" => ".000+")[1:23], ISODateTimeFormat)
fix_datetimes!(x::Type{<:Vector}) = foreach(fix_datetimes!, x)
function fix_datetimes!(x::T) where T
    for name in fieldnames(T)
        if DateTime <: fieldtype(T, name)
            f = getfield(x, name)
            if f isa String
                setfield!(x, name, parse_datetime(f))
            elseif f isa Int
                d = unix2datetime(f)
                if year(d) == 1970
                    d = unix2datetime(1000f)
                end
                setfield!(x, name, d)
            end
        end
    end
end

path_argname(s) = s
path_argname(s::Symbol) = string("<", s === :emoji_id ? :emoji : s, ">")
path_argname(ex::Expr) = path_argname(ex.args[1])


# TODO: Refactor this to be not huge and ugly.
macro route(name, method, path, kwargs...)
    if path isa String
        path = Expr(:string, path)
    end

    # Copy all the interpolations as arguments.
    fun_args = [x isa Expr ? Expr(:kw, x.args...) : x for x in path.args if !(x isa String)]
    # We'll use this later, but construct it now while `path.args` still makes sense.
    doc_path = join(map(path_argname, path.args))

    # Update the string interpolation arguments to URI-encode them, among some other hacks.
    for (i, arg) in enumerate(path.args)
        done = false
        if !(arg isa String)
            arg = if arg isa Expr && arg.head === :(=)
                k, v = arg.args
                if v === :nothing && i == lastindex(path.args)
                    # When the argument is omitted, remove the trailing slash.
                    done = true
                    path.args[i-1] = path.args[i-1][1:end-1]
                    insert!(path.args, i, :($k === nothing ? "" : "/"))
                    i += 1
                    :($k === nothing ? "" : $k)
                else
                    # Remove the default value from the interpolation.
                    k
                end
            elseif arg === :emoji_id
                # Most endpoints that accept emojis use the name,
                # so escapeuri is implemented to encode the name.
                # For the few endpoints that require the ID, this special case exists.
                fun_args[findfirst(==(:emoji_id), fun_args)] = :emoji
                :(emoji isa Emoji ? emoji.id : emoji)
            else
                arg
            end
            path.args[i] = :(escapeuri($arg))
        end
        done && break
    end

    fun = :($name(client, $(fun_args...)) = api_call(c, $(QuoteNode(method)), $path))
    pushfirst!(fun.args[2].args, __source__)

    sig_args = fun.args[1].args
    call_args = fun.args[2].args[end].args
    insert!(sig_args, 2, Expr(:parameters))
    insert!(call_args, 2, Expr(:parameters))
    sig_kws = sig_args[2].args
    call_kws = call_args[2].args
    Into = :Nothing
    for ex in kwargs
        if ex === :kwargs
            # Add trailing keywords that go into the query parameters or body.
            push!(sig_kws, :(kwargs...))
            push!(call_kws, :(kwargs...))
        elseif ex isa Expr && ex.head === :(=)
            k, v = ex.args
            if k === :array
                # Pass one specific keyword as an array body.
                pushfirst!(sig_kws, v)
                pushfirst!(call_kws, Expr(:kw, v, :(ArrayBody($v))))
            elseif k === :query
                # Add query parameters to a request that uses its keywords for the body.
                tuples = [Expr(:tuple, QuoteNode(t.args[1]), t.args[1]) for t in v.args]
                push!(call_args, Expr(:tuple, tuples...))
                for t in v.args
                    pushfirst!(sig_kws, Expr(:kw, t.args...))
                end
            end
        else
            Into = ex
        end
    end
    insert!(call_args, 6, Into)
    isempty(sig_kws) && deleteat!(sig_args, 2)
    isempty(call_kws) && deleteat!(call_args, 2)

    doc_call = replace(string(Expr(:call, sig_args...)), " = " => "=")
    doc = """
        $doc_call -> $Into

    Make a $method request to `$doc_path`.
    See [the Discord API documentation](https://discord.com/developers/docs/resources/$(RESOURCE[]))
    for more information.
    """

    block = quote
        export $name
        $fun
        @doc $doc $name
    end
    return esc(block)
end

const HasID = Union{Guild, DiscordChannel, User, Message, Overwrite, Role}
HTTP.escapeuri(x::HasID) = string(x.id)
HTTP.escapeuri(e::Emoji) = escapeuri(e.name)

const RESOURCE = Ref{String}()

RESOURCE[] = "audit-log"
@route get_guild_audit_log GET "/guilds/$guild/audit-logs" AuditLog kwargs

RESOURCE[] = "channel"
@route get_channel GET "/channels/$channel" DiscordChannel kwargs
@route update_channel PATCH "/channels/$channel" DiscordChannel kwargs
@route delete_channel DELETE "/channels/$channel" DiscordChannel
@route get_channel_messages GET "/channels/$channel/messages" Vector{Message} kwargs
@route get_channel_message GET "/channels/$channel/messages/$message" Message
@route create_message POST "/channels/$channel/messages" Message kwargs
@route create_reaction PUT "/channels/$channel/messages/$message/reactions/$emoji/@me"
@route delete_reaction DELETE "/channels/$channel/messages/$message/reactions/$emoji/$(user="@me")"
@route get_reactions GET "/channels/$channel/messages/$message/reactions/$emoji" Vector{User} kwargs
@route delete_all_reactions DELETE "/channels/$channel/messages/$message/reactions/$(emoji=nothing)"
@route update_message PATCH "/channels/$channel/messages/$message" Message kwargs
@route delete_message DELETE "/channels/$channel/messages/$message"
@route delete_messages POST "/channels/$channel/messages/bulk-delete" kwargs
@route update_channel_permissiosn PUT "/channels/$channel/permissions/$overwrite" kwargs
@route get_channel_invites GET "/channels/$channel/invites" Vector{Invite} kwargs
@route create_channel_invite POST "/channels/$channel/invites" Invite kwargs
@route delete_channel_permission DELETE "/channels/$channel/permissions/$overwrite"
@route create_typing_indicator POST "/channels/$channel/typing"
@route get_pinned_messages GET "/channels/$channel/pins" Vector{Message}
@route create_pinned_channel_message PUT "/channels/$channel/pins/$message"
@route delete_pinned_channel_message DELETE "/channels/$channel/pins/$message"
@route create_group_dm_recipient PUT "/channels/$channel/recipients/$user" kwargs
@route delete_group_dm_recipient DELETE "/channels/$channel/recipients/$user"

RESOURCE[] = "emoji"
@route get_guild_emojis GET "/guilds/$guild/emojis" Vector{Emoji}
@route get_guild_emoji GET "/guilds/$guild/emojis/$emoji_id" Emoji
@route create_guild_emoji POST "/guilds/$guild/emojis" Emoji kwargs
@route update_guild_emoji PATCH "/guilds/$guild/emojis" Emoji kwargs
@route delete_guild_emoji DELETE "/guilds/$guild/emojis/$emoji_id"

RESOURCE[] = "guild"
@route create_guild POST "/guilds" Guild kwargs
@route get_guild GET "/guilds/$guild" Guild kwargs
@route get_guild_preview GET "/guilds/$guild/preview" Guild
@route update_guild PATCH "/guilds/$guild" Guild kwargs
@route delete_guild DELETE "/guilds/$guild"
@route get_guild_channels GET "/guilds/$guild/channels" Vector{DiscordChannel}
@route create_guild_channel POST "/guilds/$guild/channels" Guild kwargs
@route update_guild_channel_positions PATCH "/guilds/$guild/channels" array=positions
@route get_guild_member GET "/guilds/$guild/members/$user" GuildMember
@route get_guild_members GET "/guilds/$guild/members" Vector{GuildMember} kwargs
@route create_guild_member PUT "/guilds/$guild/members/$user" GuildMember kwargs
@route update_guild_member PATCH "/guilds/$guild/members/$user" kwargs
@route modify_user_nick PATCH "/guilds/$guild/members/@me/nick" UserNickChange kwargs
@route create_guild_member_role PUT "/guilds/$guild/users/$user/roles/$role"
@route delete_guild_member_role DELETE "/guilds/$guild/users/$user/roles/$role"
@route delete_guild_member DELETE "/guilds/$guild/users/$user"
@route get_guild_bans GET "/guilds/$guild/bans" Vector{Guild}
@route get_guild_ban GET "/guilds/$guild/bans/$user" Ban
@route create_guild_ban PUT "/guilds/$guild/bans/$user" kwargs
@route delete_guild_ban DELETE "/guilds/$guild/bans/$user"
@route get_guild_roles GET "/guilds/$guild/roles" Vector{Role}
@route create_guild_role POST "/guilds/$guild/roles" Role kwargs
@route update_guild_role_positions PATCH "/guilds/$guild/roles" Vector{Role} array=positions
@route update_guild_role PATCH "/guilds/$guild/roles/$role" Role kwargs
@route delete_guild_role DELETE "/guilds/$guild/roles/$role"
@route get_guild_prune_count GET "/guilds/$guild/prune" PruneCount kwargs
@route create_guild_prunt POST "/guilds/$guild/prune" PruneCount kwargs
@route get_guild_voice_regions GET "/guilds/$guild/regions" Vector{VoiceRegion}
@route get_guild_invites GET "/guilds/$guild/invites" Vector{Invite}
@route get_guild_integrations GET "/guilds/$guild/integrations" Vector{Integration}
@route create_guild_integration POST "/guilds/$guild/integrations" kwargs
@route update_guild_integration PATCH "/guilds/$guild/integrations/$integration" kwargs
@route delete_guild_integration PATCH "/guilds/$guild/integrations/$integration"
@route sync_guild_integration POST "/guilds/$guild/integrations/$integration/sync"
@route get_guild_widget GET "/guilds/$guild/widget" GuildWidget
@route update_guild_widget PATCH "/guilds/$guild/widget" GuildWidget kwargs
@route get_guild_vanity_url GET "/guilds/$guild/vanity-url" Invite
@route get_guild_widget_image GET "/guilds/$guild/widget.png" String

RESOURCE[] = "invite"
@route get_invite GET "/invites/$invite" Invite kwargs
@route delete_invite DELETE "/invites/$invite" Invite

RESOURCE[] = "user"
@route get_user GET "/users/$(user="@me")" User
@route update_user PATCH "/users/@me" User kwargs
@route get_user_guilds GET "/users/@me/guilds" Vector{Guild} kwargs
@route leave_guild DELETE "/users/@me/guilds/$guild"
@route get_user_dms GET "/users/@me/channels" Vector{DiscordChannel}
@route create_dm POST "/users/@me/channels" DiscordChannel kwargs
@route create_group_dm POST "/users/@me/channels" DiscordChannel kwargs
@route get_user_connections GET "/users/@me/connections" Vector{Connection}

RESOURCE[] = "voice"
@route get_voice_regions GET "/voice/regions" Vector{VoiceRegion}

RESOURCE[] = "webhook"
@route get_channel_webhooks GET "/channels/$channel/webhooks" Vector{Webhook}
@route get_guild_webhooks GET "/guilds/$guild/webhooks" Vector{Webhook}
@route get_webhook GET "/webhooks/$webhook/$(token=nothing)" Webhook
@route update_webhook PATCH "/webhooks/$webhook/$(token=nothing)" Webhook kwargs
@route delete_webhook DELETE "/webhooks/$webhook/$(token=nothing)" Webhook kwargs
@route execute_webhook POST "/webhooks/$webhook/$token" query=(wait=true,) kwargs
@route execute_webhook_github POST "/webhooks/$webhook/$token/github" query=(wait=true,) kwargs
@route execute_webhook_slack POST "/webhooks/$webhook/$token/slack" query=(wait=true,) kwargs
