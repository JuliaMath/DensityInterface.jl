# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).

using DensityInterface
using Test

using LinearAlgebra


struct MyDensity end
@inline DensityInterface.isdensitytype(::Type{<:MyDensity}) = true
DensityInterface.logdensityof(::MyDensity, x::Any) = norm(x)^2


@testset "interface" begin
    @inferred isdensitytype(String) == false

    ref_logf(x) = norm(x)^2
    x = [1, 2, 3]

    density = MyDensity()
    @test @inferred isdensitytype(typeof(density)) == true
    @test @inferred(logdensityof(density, x)) == ref_logf(x)
    @test @inferred(logdensityof(density)) isa Base.Fix1{typeof(logdensityof)}
    log_f = logdensityof(density)
    @test @inferred(log_f(x)) == logdensityof(density, x)
    @test @inferred(logfuncdensity(log_f)) === density

    log_f = ref_logf
    @test @inferred(logfuncdensity(log_f)) isa DensityInterface.LogFuncDensity
    density = logfuncdensity(log_f)
    @test @inferred isdensitytype(typeof(density)) == true
    @test @inferred(logdensityof(density, x)) == ref_logf(x)
    @test @inferred(logdensityof(density)) === log_f
    @test @inferred(log_f(x)) == logdensityof(density, x)
end
