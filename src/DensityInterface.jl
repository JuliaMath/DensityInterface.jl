# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

"""
    DensityInterface

Trait-based interface for mathematical/statistical densities and objects
associated with a density.
"""
module DensityInterface

using InverseFunctions
using Test

include("interface.jl")
include("interface_test.jl")

end # module
