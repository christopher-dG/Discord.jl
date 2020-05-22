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

include(joinpath("routes", "audit_log.jl"))
include(joinpath("routes", "channel.jl"))
include(joinpath("routes", "emoji.jl"))
include(joinpath("routes", "guild.jl"))
include(joinpath("routes", "invite.jl"))
include(joinpath("routes", "user.jl"))
include(joinpath("routes", "voice.jl"))
include(joinpath("routes", "webhook.jl"))
