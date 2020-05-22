get_voice_regions(c) =
    api_call(c, :GET, "/voice/regions", Vector{VoiceRegion})
