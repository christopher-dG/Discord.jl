@discord_object struct AuditLog
    webhooks::Vector{Webhook}
    users::Vector{User}
    audit_log_entries::Vector{AuditLogEntry}
    integrations::Vector{Integration}
end
