@discord_object struct ActivityTimestamps
    start::Int64
    end_::Int64
end

StructTypes.names(::Type{ActivityTimestamps}) = ((:end_, :end),)
