@discord_object struct Activity
    name::String
    type::ActivityType
    url::String
    created_at::Int64  # TODO: Can this be made a DateTime?
    timestamps::ActivityTimestamps
    application_id::Snowflake
    details::String
    state::String
    emoji::ActivityEmoji
    party::ActivityParty
    assets::ActivityAssets
    secrets::ActivitySecrets
    instance::Bool
    flags::Int64

end
