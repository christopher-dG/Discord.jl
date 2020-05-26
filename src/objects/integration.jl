@discord_object struct Integration
    id::Snowflake
    name::String
    type::String
    enabled::Bool
    syncing::Bool
    role_id::Snowflake
    enable_emoticons::Bool
    expire_behavior::IntegrationExpireBehavior.IntegrationExpireBehaviorEnum
    expire_grace_period::Int
    user::User
    account::IntegrationAccount
end
