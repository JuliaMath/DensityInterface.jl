# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).


"""
    isdensity(obj::Any)

Returns `true` if `obj` is compatible with the `DensityInterface` interface,
otherwise returns `false` by default.
"""
function isdensity end
export isdensity

@inline isdensity(obj::Any) = false

function check_if_density(obj)
    isdensity(obj) || throw("Object of type $(typeof(obj)) is not a DensityInterface-compatible density")
end


"""
    logdensityof(density, x)::Real
    logdensityof(density)::Function

Computes the logarithmic value of `density` at a given point `x`, resp.
returns a function that does so:

```julia
logy = logdensityof(some_density, x)
logdensityof(some_density, x) == logdensityof(some_density)(x)
```

and

```julia
log_f = logdensityof(density)
log_f(x) == logdensityof(density, x)
logfuncdensity(log_f) == density
```

`logdensityof(density)` returns an instance of [`DensityInterface.LogDensityOf`](@ref)
by default, but may be specialized to return something else, depending on the
type of `density`). However, if a custom method is provided for
`logdensityof(density::SomeDensity)`, then a custom method must be provided for
[`logfuncdensity`](@ref) as well that guarantees

```julia
logfuncdensity(logdensityof(density)) == density
```    
"""
function logdensityof end
export logdensityof

function logdensityof(density)
    check_if_density(density)
    LogDensityOf(density)
end


"""
    logfuncdensity(log_f::Base.Callable)

Returns a `DensityInterface`-compatible density that is defined by a given
log-density function `fF`:

```julia
density = logfuncdensity(log_f)
logdensityof(density, x) == log_f(x)
logdensityof(density) == log_f
```

`logfuncdensity(log_f)` returns an instance of [`DensityInterface.LogFuncDensity`](@ref)
by default, but may be specialized to return something else depending on the
type of `log_f`).
"""
function logfuncdensity end
export logfuncdensity

logfuncdensity(log_f::Base.Callable) = LogFuncDensity(log_f)



"""
    struct DensityInterface.LogDensityOf{D} <: Function

Computes the logarithmic value of `density` at given points

Typically, `LogDensityOf(some_density)` should not be called directly,
[`logdensityof`](@ref) should be used instead.
"""
struct LogDensityOf{D} <: Function
    _density::D
end

@inline (log_f::LogDensityOf)(x) = logdensityof(log_f._density, x)

logfuncdensity(log_f::LogDensityOf) = log_f._density

function Base.show(io::IO, log_f::LogDensityOf)
    print(io, Base.typename(typeof(log_f)).name, "(")
    show(io, log_f._density)
    print(io, ")")
end

Base.show(io::IO, M::MIME"text/plain", log_f::LogDensityOf) = show(io, log_f)



"""
    struct DensityInterface.LogFuncDensity{F<:Base.Callable}

Wraps a log-density function `log_f` to make it compatible with `DensityInterface`
interface. Typically, `LogFuncDensity(log_f)` should not be called
directly, [`logfuncdensity`](@ref) should be used instead.
"""
struct LogFuncDensity{F<:Base.Callable}
    _log_f::F
end
LogFuncDensity

@inline isdensity(::LogFuncDensity) = true

@inline logdensityof(density::LogFuncDensity, x) = density._log_f(x)
@inline logdensityof(density::LogFuncDensity) = density._log_f

function Base.show(io::IO, density::LogFuncDensity)
    print(io, Base.typename(typeof(density)).name, "(")
    show(io, density._log_f)
    print(io, ")")
end
