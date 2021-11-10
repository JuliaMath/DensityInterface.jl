# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

import Test
import DensityInterface
import Documenter

Test.@testset "Package DensityInterface" begin
    include("test_interface.jl")

    # doctests
    Documenter.DocMeta.setdocmeta!(
        DensityInterface,
        :DocTestSetup,
        quote
            using DensityInterface
            d = logfuncdensity(x -> x^2)
            log_f = logdensityof(d)
            f = densityof(d)
            x = 4.2
        end;
            recursive=true,
    )
    Documenter.doctest(DensityInterface)
end # testset
