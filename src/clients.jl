abstract type AbstractClient end

abstract type AbstractToken end

struct BotToken <: AbstractToken
    token::String
end

Base.show(io::IO, t::BotToken) = print(io, "<token>")

struct BotClient <: AbstractClient
    token::BotToken

    BotClient(token) = new(BotToken(token))
end

struct BearerClient <: AbstractClient
    token::BotClient

    BearerClient(token) = new(BotToken(token))
end

auth_header(c::BotClient) = "Bot $(c.token.token)"
auth_header(c::BearerClient) = "Bearer $(c.token.token)"

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
    headers = ["Authorization" => auth_header(c), "User-Agent" => USER_AGENT]
    body, query = if method in (:PATCH, :PUT, :POST)
        push!(headers, "Content-Type" => "application/json")
        (isempty(kwargs) ? "" : JSON3.write(kwargs)), params
    else
        "", kwargs
    end
    url = "$API_BASE/v$API_VERSION$path"
    resp = request(method, url, headers, body; query=query, status_exception=false)
    # TODO: Apply rate limits.
    if resp.status in 200:299
        return parse_response(resp, Into)
    elseif resp.status == 429
        # TODO: throw some kind of RateLimitedException.
        @error "Rate limited"
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
fix_datetimes!(x::Type{<:Vector}) = foreach(fix_datetimes!, x)
function fix_datetimes!(x::T) where T
    for name in fieldnames(T)
        if DateTime <: fieldtype(T, name)
            f = getfield(x, name)
            if f isa String
                datetime = DateTime(replace(f, "+" => ".000+")[1:23], ISODateTimeFormat)
                setfield!(x, name, datetime)
            elseif f isa Int
                datetime = unix2datetime(f)
                if year(d) == 1970
                    datetime = unix2datetime(1000f)
                end
                setfield!(x, name, datetime)
            end
        end
    end
end
