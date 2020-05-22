get_guild_audit_log(c, guild; kwargs...) =
    api_call(c, :GET, "/guilds/$guild/audit-logs", AuditLog; kwargs...)
