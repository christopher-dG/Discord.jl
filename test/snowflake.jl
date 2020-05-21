for input in (1, 0x1, "1")
    s = D.Snowflake(input)
    @test s isa D.Snowflake
    @test s.n == 1
end

s = D.Snowflake(1)
@test s == 1
@test 1 == s
@test sprint(show, s) == "1"
@test JSON3.read("\"1\"", D.Snowflake) == D.Snowflake(1)
@test JSON3.write(s) == "\"1\""
