# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

using DensityInterface
using Test

using LinearAlgebra


struct MyDensity end
@inline DensityInterface.hasdensity(::MyDensity) = true
DensityInterface.logdensityof(::MyDensity, x::Any) = norm(x)^2


@testset "interface" begin
    @test @inferred(hasdensity("foo")) == false

    d1 = MyDensity()
    x = [1, 2, 3]
    DensityInterface.test_density_interface(d1, x, norm(x)^2)

    d2 = logfuncdensity(x -> norm(x)^2)
    x = [1, 2, 3]
    DensityInterface.test_density_interface(d2, x, norm(x)^2)
end
