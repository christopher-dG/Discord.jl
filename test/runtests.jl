using Test

using BrokenRecord: HTTP, configure!, playback
using JSON3: JSON3

using Discord: Discord
const D = Discord

configure!(
    path=joinpath(@__DIR__, "fixtures"),
    ignore_headers=["Authorization", "User-Agent"],
)

@testset "Discord.jl" begin
    sets = ("snowflake", "objects", "routes")
    @testset "$set" for set in sets
        include("$set.jl")
    end
end
