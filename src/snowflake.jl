struct Snowflake
    n::UInt64
end

Snowflake(s::AbstractString) = Snowflake(parse(UInt64, s))
Base.show(io::IO, s::Snowflake) = print(io, string(s.n; base=10))
Base.:(==)(s::Snowflake, n::Integer) = s.n == n
Base.:(==)(n::Integer, s::Snowflake) = n == s.n
StructTypes.StructType(::Type{Snowflake}) = StructTypes.StringType()
HTTP.escapeuri(s::Snowflake) = escapeuri(s.n)

snowflake2datetime(s::Snowflake) = unix2datetime(((s.n >> 22) + 1420070400000) / 1000)
worker_id(s::Snowflake) = (s.n & 0x3e0000) >> 17
process_id(s::Snowflake) = (s.n & 0x1f000) >> 12
increment(s::Snowflake) = s.n & 0xfff
