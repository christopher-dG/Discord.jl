const GLOBAL_BUCKET = string(gensym(:global_bucket))
const RATE_LIMIT_RETRY = gensym(:retry)
const RATE_LIMIT_SENTINEL = gensym(:rate_limited)

@enum RateLimitHandler SENTINEL THROW WAIT

mutable struct Bucket
    limit::Int
    remaining::Int
    reset::DateTime

    Bucket() = new(typemax(Int), typemax(Int), typemax(DateTime))
end

struct RateLimiter
    buckets::Dict{String, Bucket}
    routes::Dict{String, String}
    handler::RateLimitHandler

    RateLimiter(handler=WAIT) = new(Dict(), Dict(), handler)
end

struct RateLimitedError <: Exception
    reset::DateTime
    response::Union{Response, Nothing}
end

RateLimitedError(reset) = RateLimitedError(reset, nothing)

on_rate_limit(rl::RateLimiter, reset, resp=nothing) =
    on_rate_limit(Val(rl.handler), reset, resp)
on_rate_limit(::Val{SENTINEL}, reset, resp) = RATE_LIMIT_SENTINEL
on_rate_limit(::Val{THROW}, reset, resp) = throw(RateLimitedError(reset, resp))
function on_rate_limit(::Val{WAIT}, reset, resp)
    sleep(max(Millisecond(0), reset - now(UTC)))
    return RATE_LIMIT_RETRY
end

function getbucket(rl::RateLimiter, path)
    return if haskey(rl.routes, path)
        rl.buckets[rl.routes[path]]
    else
        nothing
    end
end

getbucket!(rl::RateLimiter, key) = get!(Bucket, rl.buckets, key)
setpathkey!(rl::RateLimiter, path, key) = rl.routes[path] = key

function check_rate_limits(rl, path)
    bucket = getbucket(rl, path)
    if bucket !== nothing && bucket.remaining == 0 && now(UTC) < bucket.reset
        return on_rate_limit(rl, bucket.reset)
    end
end

function apply_rate_limits!(rl, resp)
    # TODO: I'm almost 100% sure that this isn't entirely correct.
    # The documentation is incredibly unclear.

    # Remove the /api/vN prefix.
    path = resp.request.target[8:end]
    is_global = header(resp, "X-RateLimit-Global") == "true"
    key = if is_global
        GLOBAL_BUCKET
    else
        bucket_key = header(resp, "X-RateLimit-Bucket")
        isempty(bucket_key) && return
        m = match(r"^/api/v\d/(?:channels|guilds|webhooks)/(\d+)", path)
        m === nothing ? bucket_key : "$bucket_key-$(m[1])"
    end

    bucket = getbucket!(rl, key)
    seconds = parse(Float64, header(resp, "X-RateLimit-Reset"))
    bucket.reset = unix2datetime(seconds)
    bucket.limit = parse(Int, header(resp, "X-RateLimit-Limit"))
    bucket.remaining = parse(Int, header(resp, "X-RateLimit-Remaining"))

    if key != GLOBAL_BUCKET
        setpathkey!(rl, path, key)
    end

    if resp.status == 429
        return on_rate_limit(rl, bucket.reset, resp)
    end
end
