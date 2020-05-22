@discord_object struct Emoji
    id::Snowflake
    name::String
    roles::Vector{Snowflake}
    user::User
    require_colons::Bool
    managed::Bool
    animated::Bool
    available::Bool
end
