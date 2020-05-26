name = gensym()
@eval D @discord_object struct $name
    a::Snowflake
    b::Int
    c::String
end

T = getfield(D, name)
@test fieldnames(T) == (:a, :b, :c)
@test map(n -> fieldtype(T, n), fieldnames(T)) == (
    Union{D.Snowflake, D.A.Null, Nothing, Missing},
    Union{Int, D.A.Null, Nothing, Missing},
    Union{String, D.A.Null, Nothing, Missing},
)

x = T()
@test x.a === missing && x.b === missing && x.c === missing
x = JSON3.read("{}", T)
@test x.a === missing && x.b === missing && x.c === missing
@test JSON3.write(x) == "{}"
x = JSON3.read("""{"b":10}""", T)
@test x.a === missing && x.b == 10 && x.c === missing
@test JSON3.write(x) == """{"b":10}"""
x = JSON3.read("""{"b":null}""", T)
@test x.a === missing && x.b === nothing && x.c === missing
@test JSON3.write(x) == """{"b":null}"""
