@discord_object struct InviteMetadata
    uses::Int
    max_uses::Int
    max_age::Int
    temporary::Bool
    created_at::Union{String, DateTime}
end
