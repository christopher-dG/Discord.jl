@discord_object struct Connection
    id::String
    name::String
    type::String
    revoked::Bool
    integrations::Vector{Integration}
    verified::Bool
    friend_sync::Bool
    show_activity::Bool
    visibility::ConnectionVisibility
end
