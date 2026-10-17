# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

"""
    DensityInterface

Trait-based interface for mathematical/statistical densities and objects
associated with a density.
"""
module DensityInterface

using InverseFunctions

include("interface.jl")

"""
    DensityInterface.test_density_interface(object, x, ref_logd_at_x; kwargs...)

Test that `object` is compatible with `DensityInterface`.

Tests that either `DensityKind(object) isa IsOrHasDensity`.

Also tests that [`logdensityof(object, x)`](@ref) equals `ref_logd_at_x` and
that the behavior of [`logdensityof(object)`](@ref),
[`densityof(object, x)`](@ref) and [`densityof(object)`](@ref) is consistent.

The results of `logdensityof(object, x)` and `densityof(object, x)` are compared to
`ref_logd_at_x` and `exp(ref_logd_at_x)` using `isapprox`. `kwargs...` are
forwarded to `isapprox`.

Also tests that `d = logfuncdensity(logdensityof(object))` returns a density
(`DensityKind(d) == IsDensity()`) that is equivalent to `object` in respect to
`logdensityof` and `densityof`, and that `funcdensity(densityof(object))`
behaves the same way.

!!! note
    This function is available only after the `Test` standard library has been
    loaded.
"""
function test_density_interface end

function __init__()
    Base.Experimental.register_error_hint(MethodError) do io, exc, _, _
        if exc.f === test_density_interface &&
                Base.get_extension(DensityInterface, :DensityInterfaceTestExt) === nothing
            print(io, "\n`test_density_interface` requires the Test standard library; run `using Test` first.")
        end
    end
end

end # module
