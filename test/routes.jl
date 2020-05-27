const client = D.BotClient(get(ENV, "DISCORD_TOKEN", ""))

@testset "A bunch of HTTP interactions" begin
    playback("responses.bson") do
        guild = D.create_guild(client; name="MyGuild")
        try
            @test D.get_guild(client, guild.id).id == guild.id
            @test D.get_guild(client, guild).id == guild.id

            channels = D.get_guild_channels(client, guild)
            @test length(channels) == 4
            @test map(ch -> (ch.type, ch.name), channels) == [
                (D.ChannelType.GUILD_CATEGORY, "Text Channels"),
                (D.ChannelType.GUILD_CATEGORY, "Voice Channels"),
                (D.ChannelType.GUILD_TEXT, "general"),
                (D.ChannelType.GUILD_VOICE, "General"),
            ]

            text_general = channels[3]
            new_channel = D.create_guild_channel(client, guild; name="test")
            D.update_guild_channel_positions(client, guild; positions=[
                (; id=text_general.id, position=new_channel.position),
                (; id=new_channel.id, position=text_general.position),
            ])
            @test D.get_channel(client, text_general.id).position == new_channel.position
            @test D.get_channel(client, new_channel.id).position == text_general.position
        finally
            D.delete_guild(client, guild)
        end
    end
end
