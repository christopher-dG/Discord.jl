get_invite(c, invite; kwargs...) =
    api_call(c, :GET, "/invites/$invite", Invite; kwargs...)
delete_invite(c, invite) =
    api_call(c, :DELETE, "/invites/$invite", Invite)
