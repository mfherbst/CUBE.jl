using CUBE
using Documenter

DocMeta.setdocmeta!(CUBE, :DocTestSetup, :(using CUBE); recursive=true)

makedocs(;
    modules=[CUBE],
    authors="Michael F. Herbst <info@michael-herbst.com> and contributors",
    repo="https://github.com/mfherbst/CUBE.jl/blob/{commit}{path}#{line}",
    sitename="CUBE.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://mfherbst.github.io/CUBE.jl",
        edit_link="master",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/mfherbst/CUBE.jl",
    devbranch="master",
)
