@discord_object struct Webhook
    id::Snowflake
    type::WebhookType
    guild_id::Snowflake
    channel_id::Snowflake
    user::User
    name::String
    avatar::String
    token::String
end
