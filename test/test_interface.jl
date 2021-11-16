# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

using DensityInterface
using Test

using LinearAlgebra, InverseFunctions

struct MyDensity end
@inline DensityInterface.DensityKind(::MyDensity) = IsDensity()
DensityInterface.logdensityof(::MyDensity, x::Any) = -norm(x)^2

struct MyMeasure end
@inline DensityInterface.DensityKind(::MyMeasure) = HasDensity()
DensityInterface.logdensityof(::MyMeasure, x::Any) = -norm(x)^2

@testset "interface" begin
    @test inverse(logdensityof) == logfuncdensity
    @test inverse(logfuncdensity) == logdensityof
    @test inverse(densityof) == funcdensity
    @test inverse(funcdensity) == densityof

    @test @inferred(DensityKind("foo")) === NoDensity()
    @test_throws ArgumentError logdensityof("foo")
    @test_throws ArgumentError densityof("foo")

    for object1 in (MyDensity(), MyMeasure())
        x = [1, 2, 3]

        DensityInterface.test_density_interface(object1, x, -norm(x)^2)

        object2 = logfuncdensity(x -> -norm(x)^2)
        @test DensityKind(object2) === IsDensity()
        DensityInterface.test_density_interface(object2, x, -norm(x)^2)

        object3 = funcdensity(x -> exp(-norm(x)^2))
        @test DensityKind(object3) === IsDensity()
        DensityInterface.test_density_interface(object3, x, -norm(x)^2)
    end
end
