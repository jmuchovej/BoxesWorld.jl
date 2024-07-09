using BoxesWorld
using Documenter

DocMeta.setdocmeta!(BoxesWorld, :DocTestSetup, :(using BoxesWorld); recursive=true)

makedocs(;
    modules=[BoxesWorld],
    authors="John Muchovej <5000729+jmuchovej@users.noreply.github.com> and contributors",
    repo="https://github.com/jmuchovej/BoxesWorld.jl/blob/{commit}{path}#{line}",
    sitename="BoxesWorld.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://jmuchovej.github.io/BoxesWorld.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=["Home" => "index.md"],
)

deploydocs(; repo="github.com/jmuchovej/BoxesWorld.jl", devbranch="main")
