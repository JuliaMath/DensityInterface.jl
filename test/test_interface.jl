# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

using DensityInterface
using Test

using LinearAlgebra


struct MyDensity end
@inline DensityInterface.hasdensity(::MyDensity) = true
DensityInterface.logdensityof(::MyDensity, x::Any) = norm(x)^2


@testset "interface" begin
    @test @inferred(hasdensity("foo")) == false

    density = MyDensity()
    x = [1, 2, 3]

    DensityInterface.test_density_interface(density, x, norm(x)^2)
    @test @inferred(logfuncdensity(logdensityof(density))) === density
end
