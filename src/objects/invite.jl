@discord_object struct Invite
    code::String
    guild::Guild
    channel::DiscordChannel
    inviter::User
    target_user::User
    target_user_type::TargetUserType.TargetUserTypeEnum
    approximate_presence_count::Int
    approximate_member_count::Int
    # https://discord.com/developers/docs/resources/invite#invite-metadata-object
    uses::Int
    max_uses::Int
    max_age::Int
    temporary::Bool
    created_at::Union{String, DateTime}
end
