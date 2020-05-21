using Test

using Discord: Discord
using JSON3: JSON3

const D = Discord

@testset "Discord.jl" begin
    sets = ("snowflake", "objects")
    @testset "$set" for set in sets
        include("$set.jl")
    end
end
