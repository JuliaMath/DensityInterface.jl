# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

using DensityInterface
using Test

using LinearAlgebra, InverseFunctions

struct MyDensity end
@inline DensityInterface.densitykind(::MyDensity) = IsDensity()
DensityInterface.logdensityof(::MyDensity, x::Any) = -norm(x)^2

@testset "interface" begin
    @test inverse(logdensityof) == logfuncdensity
    @test inverse(logfuncdensity) == logdensityof
    @test inverse(densityof) == funcdensity
    @test inverse(funcdensity) == densityof

    @test @inferred(densitykind("foo")) == HasNoDensity()
    @test_throws ArgumentError logdensityof("foo")
    @test_throws ArgumentError densityof("foo")

    d1 = MyDensity()
    @test @inferred(densitykind(d1)) == IsDensity()
    x = [1, 2, 3]
    DensityInterface.test_density_interface(d1, x, -norm(x)^2)

    d2 = logfuncdensity(x -> -norm(x)^2)
    @test @inferred(densitykind(d2)) == IsDensity()
    x = [1, 2, 3]
    DensityInterface.test_density_interface(d2, x, -norm(x)^2)

    d3 = funcdensity(x -> exp(-norm(x)^2))
    @test @inferred(densitykind(d3)) == IsDensity()
    x = [1, 2, 3]
    DensityInterface.test_density_interface(d3, x, -norm(x)^2)
end
