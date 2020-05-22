module Discord

using Base.Iterators: Pairs

using Dates: DateTime, ISODateTimeFormat, UTC, now, unix2datetime, year

using HTTP: Response, StatusError, URI, escapeuri, header, request
using JSON3: JSON3, StructTypes
using Parameters: @with_kw

const API_BASE = "https://discord.com/api"
const API_VERSION = 6
const USER_AGENT = let
    toml = read(joinpath(@__DIR__, "..", "Project.toml"), String)
    version = VersionNumber(match(r"version = \"(.*)\"", toml)[1])
    "Julia $VERSION / Discord.jl $version"
end

include("snowflake.jl")
include("objects.jl")
include("rate_limiter.jl")
include("clients.jl")
include(joinpath("endpoints", "audit_log.jl"))
include(joinpath("endpoints", "channel.jl"))
include(joinpath("endpoints", "emoji.jl"))
include(joinpath("endpoints", "guild.jl"))
include(joinpath("endpoints", "invite.jl"))
include(joinpath("endpoints", "user.jl"))
include(joinpath("endpoints", "voice.jl"))
include(joinpath("endpoints", "webhook.jl"))


end
