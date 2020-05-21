module Discord

using JSON3: JSON3, StructTypes
using Parameters: @with_kw

const API_URL = "https://discord.com/api"
const API_VERSION = 6

include("snowflake.jl")
include("objects.jl")

end
