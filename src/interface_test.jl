# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

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
"""
function test_density_interface(object, x, ref_logd_at_x; kwargs...)
    @testset "test_density_interface: $object with input $x" begin
        ref_d_at_x = exp(ref_logd_at_x)

        @test DensityKind(object) isa IsOrHasDensity

        @test isapprox(logdensityof(object, x), ref_logd_at_x; kwargs...)
        log_f = logdensityof(object)
        @test isapprox(log_f(x), ref_logd_at_x; kwargs...)

        @test isapprox(densityof(object,x), ref_d_at_x; kwargs...)
        f = densityof(object)
        @test isapprox(f(x), ref_d_at_x; kwargs...)

        for d in (logfuncdensity(log_f), funcdensity(f))
            @test DensityKind(d) == IsDensity()
            @test isapprox(logdensityof(d, x), ref_logd_at_x; kwargs...)
            @test isapprox(logdensityof(d)(x), ref_logd_at_x; kwargs...)
            @test isapprox(densityof(d,x), ref_d_at_x; kwargs...)
            @test isapprox(densityof(d)(x), ref_d_at_x; kwargs...)
        end
    end
end
