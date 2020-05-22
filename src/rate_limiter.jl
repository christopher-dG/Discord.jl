const GLOBAL_BUCKET = string(gensym(:global_bucket))

mutable struct Bucket
    limit::Int
    remaining::Int
    reset::DateTime

    Bucket() = new(typemax(Int), typemax(Int), typemax(DateTime))
end

struct RateLimiter
    buckets::Dict{String, Bucket}
    routes::Dict{String, String}

    RateLimiter() = new(Dict(GLOBAL_BUCKET => Bucket()), Dict())
end

struct RateLimitedError <: Exception
    reset::DateTime
    response::Union{Response, Nothing}
end

RateLimitedError(reset) = RateLimitedError(reset, nothing)

function check_rate_limits(rl, url)
    path = URI(url).path
    if haskey(rl.routes, path)
        bucket = rl.buckets[rl.routes[path]]
        if bucket.remaining == 0 && now(UTC) < bucket.reset
            throw(RateLimitedError(bucket.reset))
        end
    end
end

function apply_rate_limits!(rl, resp)
    # TODO: I'm almost 100% sure that this isn't entirely correct.
    # The documentation is incredibly unclear.
    path = URI(resp.request.target).path
    is_global = header(resp, "X-RateLimit-Global") == "true"
    key = if is_global
        GLOBAL_BUCKET
    else
        bucket_key = header(resp, "X-RateLimit-Bucket")
        isempty(bucket_key) && return
        m = match(r"^/api/v\d/(?:channels|guilds|webhooks)/(\d+)", @show path)
        m === nothing ? bucket_key : "$bucket_key-$(m[1])"
    end

    bucket = get!(Bucket, rl.buckets, key)
    seconds = parse(Float64, header(resp, "X-RateLimit-Reset"))
    bucket.reset = unix2datetime(seconds)
    bucket.limit = parse(Int, header(resp, "X-RateLimit-Limit"))
    bucket.remaining = parse(Int, header(resp, "X-RateLimit-Remaining"))

    if key != GLOBAL_BUCKET
        rl.routes[path] = key
    end

    if resp.status == 429
        throw(RateLimitedError(bucket.reset, resp))
    end
end
