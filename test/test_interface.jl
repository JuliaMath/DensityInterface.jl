# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

using DensityInterface
using Test

using LinearAlgebra, InverseFunctions

struct MyDensity end
@inline DensityInterface.isdensity(::MyDensity) = true
DensityInterface.logdensityof(::MyDensity, x::Any) = -norm(x)^2

struct MyMeasure end
@inline DensityInterface.hasdensity(::MyMeasure) = true
DensityInterface.logdensityof(::MyMeasure, x::Any) = -norm(x)^2

@testset "interface" begin
    @test inverse(logdensityof) == logfuncdensity
    @test inverse(logfuncdensity) == logdensityof
    @test inverse(densityof) == funcdensity
    @test inverse(funcdensity) == densityof

    @test @inferred(isdensity("foo")) == false
    @test @inferred(hasdensity("foo")) == false
    @test_throws ArgumentError logdensityof("foo")
    @test_throws ArgumentError densityof("foo")

    for object1 in (MyDensity(), MyMeasure())
        x = [1, 2, 3]

        object1 = MyDensity()
        DensityInterface.test_density_interface(object1, x, -norm(x)^2)

        object2 = logfuncdensity(x -> -norm(x)^2)
        @test isdensity(object2)
        DensityInterface.test_density_interface(object2, x, -norm(x)^2)

        object3 = funcdensity(x -> exp(-norm(x)^2))
        @test isdensity(object3)
        DensityInterface.test_density_interface(object3, x, -norm(x)^2)
    end
end
