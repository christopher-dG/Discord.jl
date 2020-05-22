abstract type AbstractToken end
Base.show(io::IO, ::AbstractToken) = print(io, "<token>")

struct BotToken <: AbstractToken
    token::String
end

abstract type AbstractClient end

struct BotClient <: AbstractClient
    token::BotToken
    rate_limiter::RateLimiter

    BotClient(token) = new(BotToken(token), RateLimiter())
end

struct BearerClient <: AbstractClient
    token::BotClient
    rate_limiter::RateLimiter

    BearerClient(token) = new(BotToken(token), RateLimiter())
end

auth_header(c::BotClient) = "Bot $(c.token.token)"
auth_header(c::BearerClient) = "Bearer $(c.token.token)"

rate_limiter(c::BotClient) = c.rate_limiter
rate_limiter(c::BearerClient) = c.rate_limiter

# A hack to make it easier to pass in an array payload.
# TODO: This doesn't quite work.
struct JSONArray{T}
    xs::T
end
const ArrayKwarg =
    Pairs{Symbol, JSONArray{T}, Tuple{Symbol}, NamedTuple{(:array,), Tuple{JSONArray{T}}}} where T
Base.iterate(kw::ArrayKwarg) = iterate(kw.data.array.xs)
Base.iterate(kw::ArrayKwarg, state) = iterate(kw.data.array.xs, state)
StructTypes.StructType(::Type{<:ArrayKwarg}) = StructTypes.ArrayType()

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
    check_rate_limits(rate_limiter(c), url)
    resp = request(method, url, headers, body; query=query, status_exception=false)
    apply_rate_limits!(rate_limiter(c), resp)
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
