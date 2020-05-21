using Discord
using Documenter

makedocs(;
    modules=[Discord],
    authors="Chris de Graaf <me@cdg.dev> and contributors",
    repo="https://github.com/christopher-dG/Discord.jl/blob/{commit}{path}#L{line}",
    sitename="Discord.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://christopher-dG.github.io/Discord.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/christopher-dG/Discord.jl",
)
