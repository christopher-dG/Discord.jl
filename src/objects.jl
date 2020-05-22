function json(x)
    data = Dict{Symbol, Any}()
    for name in propertynames(x)
        val = getproperty(x, name)
        if !ismissing(val)
            data[name] = val
        end
    end
    return JSON3.write(data)
end

macro discord_object(typedef)
    # Make the type mutable.
    typedef.args[1] = true

    # Make all the types nullable/optional with a default value of `missing`.
    fields = typedef.args[3].args
    for (i, field) in enumerate(fields)
        if field isa Expr
            type = field.args[2]
            field.args[2] = :(Union{$type, Nothing, Missing})
            fields[i] = :($field = missing)
        end
    end
    typedef_withkw = esc(:(@with_kw $typedef))

    # Enable JSON IO for the type.
    # TODO: Figure out how to get nulls to deserialize into `nothing`.
    name = esc(typedef.args[2])
    json_methods = quote
        StructTypes.StructType(::Type{$name}) = StructTypes.Mutable()
        JSON3.write(x::$name) = json(x)
    end

    return quote
        $typedef_withkw
        $json_methods
    end
end

macro discord_enum(name, block)
    # TODO: Why do I need to eval here? I want to just insert a macrocall expression.
    @eval @enum $name $block
    return quote
        StructTypes.StructType(::Type{$(esc(name))}) = StructTypes.NumberType()
        StructTypes.numbertype(::Type{$(esc(name))}) = UInt64
    end
end

include(joinpath("objects", "enums.jl"))
include(joinpath("objects", "user.jl"))
include(joinpath("objects", "integration_account.jl"))
include(joinpath("objects", "integration.jl"))
include(joinpath("objects", "connection.jl"))
include(joinpath("objects", "overwrite.jl"))
include(joinpath("objects", "channel.jl"))
include(joinpath("objects", "channel_mention.jl"))
include(joinpath("objects", "guild_member.jl"))
include(joinpath("objects", "attachment.jl"))
include(joinpath("objects", "embed_footer.jl"))
include(joinpath("objects", "embed_image.jl"))
include(joinpath("objects", "embed_thumbnail.jl"))
include(joinpath("objects", "embed_video.jl"))
include(joinpath("objects", "embed_provider.jl"))
include(joinpath("objects", "embed_author.jl"))
include(joinpath("objects", "embed_field.jl"))
include(joinpath("objects", "embed.jl"))
include(joinpath("objects", "emoji.jl"))
include(joinpath("objects", "reaction.jl"))
include(joinpath("objects", "message_activity.jl"))
include(joinpath("objects", "message_application.jl"))
include(joinpath("objects", "message_reference.jl"))
include(joinpath("objects", "message.jl"))
include(joinpath("objects", "role.jl"))
include(joinpath("objects", "voice_state.jl"))
include(joinpath("objects", "activity_timestamps.jl"))
include(joinpath("objects", "activity_emoji.jl"))
include(joinpath("objects", "activity_party.jl"))
include(joinpath("objects", "activity_assets.jl"))
include(joinpath("objects", "activity_secrets.jl"))
include(joinpath("objects", "activity.jl"))
include(joinpath("objects", "client_status.jl"))
include(joinpath("objects", "presence_update.jl"))
include(joinpath("objects", "guild.jl"))
include(joinpath("objects", "guild_widget.jl"))
include(joinpath("objects", "webhook.jl"))
include(joinpath("objects", "audit_log_change.jl"))
include(joinpath("objects", "audit_log_info.jl"))
include(joinpath("objects", "audit_log_entry.jl"))
include(joinpath("objects", "audit_log.jl"))
include(joinpath("objects", "allowed_mentions.jl"))
include(joinpath("objects", "ban.jl"))
include(joinpath("objects", "invite.jl"))
include(joinpath("objects", "voice_region.jl"))
include(joinpath("objects", "prune_count.jl"))
