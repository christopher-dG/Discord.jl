@discord_object struct Message
    id::Snowflake
    channel_id::Snowflake
    guild_id::Snowflake
    author::User
    member::GuildMember
    content::String
    timestamp::Union{String, DateTime}
    edited_timestamp::Union{String, DateTime}
    tts::Bool
    mention_everyone::Bool
    mentions::Vector{User}
    mention_roles::Vector{Snowflake}
    mention_channels::Vector{ChannelMention}
    attachments::Vector{Attachment}
    embeds::Vector{Embed}
    reactions::Vector{Reaction}
    nonce::Union{Int, String}
    pinned::Bool
    webhook_id::Snowflake
    type::MessageType
    activity::MessageActivity
    application::MessageApplication
    message_reference::MessageReference
    message_flags::Int
end
