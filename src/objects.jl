function json(x)
    data = Dict{Symbol, Any}()
    for name in propertynames(x)
        val = getproperty(x, name)
        if !ismissing(val)
            data[name] = val
        end
    end
    return JSON3.write(data)
end

macro discord_object(typedef::Expr)
    # Make the type mutable.
    typedef.args[1] = true

    # Make all the types nullable/optional with a default value of `missing`.
    fields = typedef.args[3].args
    for (i, field) in enumerate(fields)
        if field isa Expr
            type = field.args[2]
            field.args[2] = :(Union{$type, Nothing, Missing})
            fields[i] = :($field = missing)
        end
    end
    typedef_withkw = esc(:(@with_kw $typedef))

    # Enable JSON IO for the type.
    name = esc(typedef.args[2])
    json_methods = quote
        StructTypes.StructType(::Type{$name}) = StructTypes.Mutable()
        StructTypes.construct(::Type{$name}, ::Nothing) = nothing
        JSON3.write(x::$name) = json(x)
    end

    return quote
        $typedef_withkw
        $json_methods
    end
end
