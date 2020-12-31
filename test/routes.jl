const UP = "👍"
const DOWN = "👎"
const client = D.BotClient(get(ENV, "DISCORD_TOKEN", ""))

function testset(f, name)
    @testset "$name" begin
        playback(name) do ctx
            guild = off_record!(ctx) do
                if ctx.recording
                    g = D.create_guild(client; name="MyGuild")
                    ctx.guild = g.id
                    g
                else
                    D.get_guild(client, ctx.guild)
                end
            end
            try
                playback(() -> f(guild), name)
            finally
                ctx.recording && off_record!(() -> D.delete_guild(client, guild), ctx)
            end
        end
    end
end

user = D.get_user(client)

try
    testset("get with id or object") do guild
        @test D.get_guild(client, guild.id).id == guild.id
        @test D.get_guild(client, guild).id == guild.id
    end

    testset("channels") do guild
        # Loading channels.
        channels = D.get_guild_channels(client, guild)
        @test length(channels) == 4
        @test map(ch -> (ch.type, ch.name), channels) == [
            (D.ChannelType.GUILD_CATEGORY, "Text Channels"),
            (D.ChannelType.GUILD_CATEGORY, "Voice Channels"),
            (D.ChannelType.GUILD_TEXT, "general"),
            (D.ChannelType.GUILD_VOICE, "General"),
        ]
        # Reordering channels
        channel = D.create_guild_channel(client, guild; name="test1")
        text_general = channels[3]
        D.update_guild_channel_positions(client, guild; positions=[
            (; id=text_general.id, position=channel.position),
            (; id=channel.id, position=text_general.position),
        ])
        @test D.get_channel(client, text_general.id).position == channel.position
        @test D.get_channel(client, channel.id).position == text_general.position
        # Updating + deleting channels.
        channel = D.update_channel(client, channel; name="test2")
        @test channel.name == "test2"
        D.delete_channel(client, channel)
    end

    testset("messages") do guild
        # Create + get messages.
        channel = D.create_guild_channel(client, guild; name="test2")
        message = D.create_message(client, channel; content="hello")
        @test message.content == "hello"
        @test message.timestamp isa DateTime
        @test D.get_channel_message(client, channel, message).id == message.id
        messages = D.get_channel_messages(client, channel)
        @test length(messages) == 1 && messages[1].id == message.id
        @test messages[1].timestamp isa DateTime
        # Creating, listing, deleting reactions.
        D.create_reaction(client, channel, message, UP)
        users = D.get_reactions(client, channel, message, UP)
        @test length(users) == 1 && users[1].id == user.id
        D.delete_reaction(client, channel, message, UP)
        D.create_reaction(client, channel, message, UP)
        D.create_reaction(client, channel, message, DOWN)
        D.delete_all_reactions(client, channel, message, UP)
        @test isempty(D.get_reactions(client, channel, message, UP))
        @test !isempty(D.get_reactions(client, channel, message, DOWN))
        D.delete_all_reactions(client, channel, message)
        @test isempty(D.get_reactions(client, channel, message, DOWN))
        # Updating + deleting messages.
        @test D.update_message(client, channel, message; content="a").content == "a"
        D.delete_message(client, channel, message)
        @test isempty(D.get_channel_messages(client, channel))
        ids = map(i -> D.create_message(client, channel; content="hi").id, 1:5)
        @test length(D.get_channel_messages(client, channel)) == 5
        D.delete_messages(client, channel; messages=ids)
        @test isempty(D.get_channel_messages(client, channel))
    end

    testset("invites") do guild
        channel = D.create_guild_channel(client, guild; name="test3")
        @test isempty(D.get_channel_invites(client, channel))
        @test isempty(D.get_guild_invites(client, guild))
        invite = D.create_channel_invite(client, channel)
        invites = D.get_channel_invites(client, channel)
        @test length(invites) == 1 && invites[1].code == invite.code
        invites = D.get_guild_invites(client, guild)
        @test length(invites) == 1 && invites[1].code == invite.code
        @test D.get_invite(client, invite).code == invite.code
        @test D.delete_invite(client, invite).code == invite.code
        @test isempty(D.get_channel_invites(client, channel))
        @test isempty(D.get_guild_invites(client, guild))
    end

    testset("pins and typing") do guild
        channel = D.create_guild_channel(client, guild; name="test4")
        D.create_typing_indicator(client, channel)
        @test isempty(D.get_pinned_messages(client, channel))
        message = D.create_message(client, channel; content="pin")
        D.create_pinned_channel_message(client, channel, message)
        pins = D.get_pinned_messages(client, channel)
        @test length(pins) == 1 && pins[1].id == message.id
        D.delete_pinned_channel_message(client, channel, message)
        @test isempty(D.get_pinned_messages(client, channel))
    end

    testset("emojis") do guild
        @test isempty(D.get_guild_emojis(client, guild))
        # TODO: Figure out how to properly send the payload.
        # png = read(joinpath(@__DIR__, "emoji.png"), String)
        # emoji = D.create_guild_emoji(client, guild; name="test", image=png)
        # emojis = D.get_guild_emojis(client, guild)
        # @test length(emojis) == 1 && emojis[1].id == emoji.id
        # @test D.update_guild_emoji(client, guild, emoji; name="test2").name == "test2"
        # @test D.get_guild_emoji(client, guild, emoji).name == "test2"
        # D.delete_guild_emoji(client, guild, emoji)
        # @test isempty(D.get_guild_emojis(client, guild))
    end

    testset("guilds and members") do guild
        # Guilds/members.
        @test D.get_guild(client, guild).id == guild.id
        @test D.update_guild(client, guild; name="test2").name == "test2"
        @test D.get_guild_member(client, guild, user).user.id == user.id
        # This is throwing 403, I don't know why.
        # members = D.get_guild_members(client, guild)
        # @test length(members) == 1 && members[1].user.id == user.id
        # @test D.modify_user_nick(client, guild; nick="test3").nick == "test3"
        # @test D.get_guild_member(client, guild, user).nick == "test3"
    end

    testset("roles") do guild
        roles = D.get_guild_roles(client, guild)
        @test length(roles) == 1 && roles[1].name == "@everyone"
        role = D.create_guild_role(client, guild; name="test")
        @test role.name == "test"
        roles = D.get_guild_roles(client, guild)
        @test length(roles) == 2 && roles[2].id == role.id
        @test D.update_guild_role(client, guild, role; name="test2").name == "test2"
        D.create_guild_member_role(client, guild, user, role)
        role_ids = D.get_guild_member(client, guild, user).roles
        @test length(role_ids) == 1 && role_ids[1] == role.id
        D.delete_guild_member_role(client, guild, user, role)
        @test isempty(D.get_guild_member(client, guild, user).roles)
        D.delete_guild_role(client, guild, role)
        roles = D.get_guild_roles(client, guild)
        @test length(roles) == 1 && roles[1].name == "@everyone"
    end

    testset("webhooks") do guild
        channel = D.create_guild_channel(client, guild; name="test5")
        @test isempty(D.get_channel_webhooks(client, channel))
        @test isempty(D.get_guild_webhooks(client, guild))
        webhook = D.create_webhook(client, channel; name="test")
        @test webhook.name == "test"
        @test D.get_webhook(client, webhook).id == webhook.id
        webhooks = D.get_channel_webhooks(client, channel)
        @test length(webhooks) == 1 && webhooks[1].id == webhook.id
        webhooks = D.get_guild_webhooks(client, guild)
        @test length(webhooks) == 1 && webhooks[1].id == webhook.id
        @test D.update_webhook(client, webhook; name="test2").name == "test2"
        message = D.execute_webhook(client, webhook, webhook.token; content="hi")
        @test message.content == "hi"
        D.delete_webhook(client, webhook)
        @test isempty(D.get_channel_webhooks(client, channel))
        @test isempty(D.get_guild_webhooks(client, guild))
    end

    testset("misc") do guild
        @test eltype(D.get_guild_voice_regions(client, guild)) === D.VoiceRegion
        @test eltype(D.get_voice_regions(client)) === D.VoiceRegion
        @test isempty(D.get_guild_bans(client, guild))
        @test length(D.get_guild_integrations(client, guild)) == 1
        @test D.get_guild_prune_count(client, guild).pruned == 0
        @test !D.get_guild_widget(client, guild).enabled
    end

    testset("sending files") do guild
        channel = D.create_guild_channel(client, guild; name="test6")
        msg = mktempdir() do dir
            file = joinpath(dir, "foo.json")
            write(file, "{}")
            open(file) do f
                D.create_message(client, channel; file=f, __boundary__="abcdef")
            end
        end
        attachments = msg.attachments
        @test length(attachments) == 1
        attachment = attachments[1]
        @test attachment.filename == "foo.json"
        @test attachment.size == 2
    end
finally

end
