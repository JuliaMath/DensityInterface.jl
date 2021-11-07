# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

"""
    DensityInterface.test_density_interface(d, x, ref_logd_at_x; compare=isapprox, kwargs...)

Test if `d` is compatible with `DensityInterface`.

Tests that [`logdensityof(d, x)`](@ref) equals `ref_logd_at_x` and
that the behavior of [`logdensityof(d)`](@ref),
[`densityof(d, x)`](@ref) and [`densityof(d)`](@ref) is consistent.

Also tests if `logfuncdensity(logdensityof(d))` returns
a density equivalent to `d` in respect to the functions above.

The results of `logdensityof(d, x)` and `densityof(d, x)` are compared to
`ref_logd_at_x` and `exp(ref_logd_at_x)` using `compare`. `kwargs...` are
forwarded to `compare`.
"""
function test_density_interface(d, x, ref_logd_at_x; compare=isapprox, kwargs...)
    @testset "test_density_interface: $d with input $x" begin
        ref_d_at_x = exp(ref_logd_at_x)

        @test hasdensity(d) == true
        @test compare(logdensityof(d, x), ref_logd_at_x; kwargs...)
        log_f = logdensityof(d)
        @test compare(log_f(x), ref_logd_at_x; kwargs...)
        @test compare(densityof(d,x), ref_d_at_x; kwargs...)
        @test compare(densityof(d)(x), ref_d_at_x; kwargs...)

        d2 = logfuncdensity(log_f)
        @test hasdensity(d2) == true
        @test compare(logdensityof(d2, x), ref_logd_at_x; kwargs...)
        log_f2 = logdensityof(d2)
        @test compare(log_f2(x), ref_logd_at_x; kwargs...)
        @test compare(densityof(d2,x), ref_d_at_x; kwargs...)
        @test compare(densityof(d2)(x), ref_d_at_x; kwargs...)
    end
end
