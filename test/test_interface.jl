# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

using DensityInterface
using Test

using LinearAlgebra, InverseFunctions

# !!TODO: Add tests for measures!!

struct MyDensity end
@inline DensityInterface.hasdensity(::MyDensity) = true
DensityInterface.logdensityof(::MyDensity, x::Any) = -norm(x)^2

@testset "interface" begin
    @test inverse(logdensityof) == logfuncdensity
    @test inverse(logfuncdensity) == logdensityof
    @test inverse(densityof) == funcdensity
    @test inverse(funcdensity) == densityof

    @test @inferred(hasdensity("foo")) == false
    @test @inferred(ismeasure("foo")) == false
    @test @inferred(isdensity("foo")) == false
    @test_throws ArgumentError logdensityof("foo")
    @test_throws ArgumentError densityof("foo")

    d1 = MyDensity()
    @test @inferred(ismeasure(d1)) == false
    @test @inferred(isdensity(d1)) == true
    x = [1, 2, 3]
    DensityInterface.test_density_interface(d1, x, -norm(x)^2)

    d2 = logfuncdensity(x -> -norm(x)^2)
    @test @inferred(ismeasure(d2)) == false
    @test @inferred(isdensity(d2)) == true
    x = [1, 2, 3]
    DensityInterface.test_density_interface(d2, x, -norm(x)^2)

    d3 = funcdensity(x -> exp(-norm(x)^2))
    @test @inferred(ismeasure(d3)) == false
    @test @inferred(isdensity(d3)) == true
    x = [1, 2, 3]
    DensityInterface.test_density_interface(d3, x, -norm(x)^2)
end
