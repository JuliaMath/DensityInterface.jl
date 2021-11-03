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
        :(using DensityInterface);
        recursive=true,
    )
    Documenter.doctest(DensityInterface)
end # testset
