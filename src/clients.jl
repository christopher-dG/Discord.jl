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
