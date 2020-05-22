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

function make_request(c, method, path, Into; body="", query=Dict(), kwargs...)
    headers = ["Authorization" => auth_header(c), "User-Agent" => USER_AGENT]
    isempty(body) || push!(headers, "Content-Type" => "application/json")
    url = "$API_BASE/v$API_VERSION$path"
    resp = HTTP.request(method, url, headers, body; query=query, status_exception=false)
    if resp.status in 200:299
        obj = JSON3.read(resp.body, Into)
        fix_datetimes!(obj)
        return obj
    else
    end
end

# I hate this.
fix_datetimes!(x::Type{<:Vector}) = foreach(fix_datetimes!, x)
function fix_datetimes!(x::T) where T
    for name in fieldnames(T)
        if DateTime <: fieldtype(T, name)
            s = getfield(x, name)
            if s isa String
                datetime = DateTime(replace(s, "+" => ".000+")[1:23], ISODateTimeFormat)
                setfield!(x, name, datetime)
            end
        end
    end
end
