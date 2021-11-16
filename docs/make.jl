# Use
#
#     DOCUMENTER_DEBUG=true julia --color=yes make.jl local [nonstrict] [fixdoctests]
#
# for local builds.

using Documenter
using DensityInterface

# Doctest setup
DocMeta.setdocmeta!(
    DensityInterface,
    :DocTestSetup,
    quote
        using DensityInterface
        object = logfuncdensity(x -> -x^2)
        log_f = logdensityof(object)
        f = densityof(object)
        x = 4
    end;
    recursive=true,
)

makedocs(
    sitename = "DensityInterface",
    modules = [DensityInterface],
    format = Documenter.HTML(
        prettyurls = !("local" in ARGS),
        canonical = "https://JuliaMath.github.io/DensityInterface.jl/stable/"
    ),
    pages = [
        "Home" => "index.md",
        "API" => "api.md",
        "LICENSE" => "LICENSE.md",
    ],
    doctest = ("fixdoctests" in ARGS) ? :fix : true,
    linkcheck = !("nonstrict" in ARGS),
    strict = !("nonstrict" in ARGS),
)

deploydocs(
    repo = "github.com/JuliaMath/DensityInterface.jl.git",
    forcepush = true,
    push_preview = true,
)
