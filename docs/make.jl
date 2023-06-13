using BoxWorld
using Documenter

DocMeta.setdocmeta!(BoxWorld, :DocTestSetup, :(using BoxWorld); recursive=true)

makedocs(;
    modules=[BoxWorld],
    authors="John Muchovej <5000729+jmuchovej@users.noreply.github.com> and contributors",
    repo="https://github.com/jmuchovej/BoxWorld.jl/blob/{commit}{path}#{line}",
    sitename="BoxWorld.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://jmuchovej.github.io/BoxWorld.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/jmuchovej/BoxWorld.jl",
    devbranch="main",
)
