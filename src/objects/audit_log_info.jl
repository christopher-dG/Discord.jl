@discord_object struct AuditLogInfo
    delete_member_days::String
    members_removed::String
    channel_id::Snowflake
    message_id::Snowflake
    count::String
    id::Snowflake
    type::String
    role_name::String
end
