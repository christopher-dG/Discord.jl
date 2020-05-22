@discord_object struct Invite
    code::String
    guild::Guild
    channel::DiscordChannel
    inviter::User
    target_user::User
    target_user_type::TargetUserType
    approximate_presence_count::Int
    approximate_member_count::Int
end
