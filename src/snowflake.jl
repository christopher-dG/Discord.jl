struct Snowflake
    n::UInt64
end

Snowflake(s::AbstractString) = Snowflake(parse(UInt64, s))
Base.convert(::Type{Snowflake}, s::AbstractString) = Snowflake(s)
Base.show(io::IO, s::Snowflake) = print(io, string(s.n; base=10))
Base.:(==)(s::Snowflake, n::Integer) = s.n == n
Base.:(==)(n::Integer, s::Snowflake) = n == s.n
StructTypes.StructType(::Type{Snowflake}) = StructTypes.StringType()
