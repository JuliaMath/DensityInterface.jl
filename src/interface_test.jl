# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

"""
    DensityInterface.test_density_interface(d, x, ref_logd_at_x)

Test if `d` is compatible with `DensityInterface`.

Tests that [`logdensityof(d, x)`](@ref) equals `ref_logd_at_x` and
that the behavior of [`logdensityof(d)`](@ref),
[`densityof(d, x)`](@ref) and [`densityof(d)`](@ref) is consistent.

Also tests if `logfuncdensity(logdensityof(d)) == d`.
"""
function test_density_interface(d, x, ref_logd_at_x)
    @testset "test_density_interface: $d with input $x" begin
        ref_d_at_x = exp(ref_logd_at_x)

        @test hasdensity(d) == true
        @test logdensityof(d, x) == ref_logd_at_x
        log_f = logdensityof(d)
        @test log_f(x) == ref_logd_at_x
        @test densityof(d,x) == ref_d_at_x
        @test densityof(d)(x) == ref_d_at_x

        @test logfuncdensity(logdensityof(d)) == d
    end
end
