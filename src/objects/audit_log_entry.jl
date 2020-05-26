@discord_object struct AuditLogEntry
    target_id::String
    changes::Vector{AuditLogChange}
    user_id::Snowflake
    id::Snowflake
    action_type::AuditLogEvent.AuditLogEventEnum
    options::AuditLogInfo
    reason::String
end
