# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

"""
    DensityInterface.test_density_interface(o, x, ref_logd_at_x; kwargs...)

Test if `o` is compatible with `DensityInterface`.

Tests that [`logdensityof(o, x)`](@ref) equals `ref_logd_at_x` and
that the behavior of [`logdensityof(o)`](@ref),
[`densityof(o, x)`](@ref) and [`densityof(o)`](@ref) is consistent.

Also tests if `logfuncdensity(logdensityof(o))` returns
a density equivalent to `o` in respect to the functions above.

The results of `logdensityof(o, x)` and `densityof(o, x)` are compared to
`ref_logd_at_x` and `exp(ref_logd_at_x)` using `isapprox`. `kwargs...` are
forwarded to `isapprox`.
"""
function test_density_interface(o, x, ref_logd_at_x; kwargs...)
    @testset "test_density_interface: $o with input $x" begin
        ref_d_at_x = exp(ref_logd_at_x)

        @test hasdensity(o)
        @test isdensity(o) ⊻ ismeasure(o)

        @test isapprox(logdensityof(o, x), ref_logd_at_x; kwargs...)
        log_f = logdensityof(o)
        @test isapprox(log_f(x), ref_logd_at_x; kwargs...)

        @test isapprox(densityof(o,x), ref_d_at_x; kwargs...)
        f = densityof(o)
        @test isapprox(f(x), ref_d_at_x; kwargs...)

        for o2 in (logfuncdensity(log_f), funcdensity(f))
            @test hasdensity(o2)
            @test isdensity(o2) && !ismeasure(o2)
            @test isapprox(logdensityof(o2, x), ref_logd_at_x; kwargs...)
            @test isapprox(logdensityof(o2)(x), ref_logd_at_x; kwargs...)
            @test isapprox(densityof(o2,x), ref_d_at_x; kwargs...)
            @test isapprox(densityof(o2)(x), ref_d_at_x; kwargs...)
        end
    end
end
