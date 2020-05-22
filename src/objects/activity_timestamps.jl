@discord_object struct ActivityTimestamps
    start::Union{Int, DateTime}
    end_::Union{Int, DateTime}
end

StructTypes.names(::Type{ActivityTimestamps}) = ((:end_, :end),)
