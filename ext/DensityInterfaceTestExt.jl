# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

module DensityInterfaceTestExt

using Test: @test, @testset
using DensityInterface: DensityInterface, DensityKind, IsDensity, IsOrHasDensity,
    logdensityof, densityof, logfuncdensity, funcdensity

function DensityInterface.test_density_interface(object, x, ref_logd_at_x; kwargs...)
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

end # module
