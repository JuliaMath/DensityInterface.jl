# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).


"""
    hasdensity(d::Any)

Returns `true` if `d` is compatible with the `DensityInterface` interface,
implying that has an associated density (function) or is a density itself.
"""
function hasdensity end
export hasdensity

@inline hasdensity(::Any) = false

function check_hasdensity(d)
    hasdensity(d) || throw("Object of type $(typeof(d)) is not compatible with DensityInterface")
end


"""
    logdensityof(density, x)::Real
    logdensityof(density)

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

`logdensityof(density)` defaults to `Base.Fix1(logdensityof, density)`, but
may be specialized for specific density-like types. If so,
[`logfuncdensity`](@ref) will typically have to be specialized for the return
type of `logdensityof` as well.
    
The following identity must always hold:

```julia
logfuncdensity(logdensityof(density)) == density
```

See also [`densityof`](@ref).
"""
function logdensityof end
export logdensityof

function logdensityof(density)
    check_hasdensity(density)
    Base.Fix1(logdensityof, density)
end


"""
    logfuncdensity(log_f)

Returns a `DensityInterface`-compatible density that is defined by a given
log-density function `log_f`:

```julia
density = logfuncdensity(log_f)
logdensityof(density, x) == log_f(x)
logdensityof(density) == log_f
```

`logfuncdensity(log_f)` returns an instance of [`DensityInterface.LogFuncDensity`](@ref)
by default, but may be specialized to return something else depending on the
type of `log_f`). If so, [`logdensityof`](@ref) will typically have to be
specialized for the return type of `logfuncdensity` as well.
    
The following identity must always hold:

```julia
logfuncdensity(logdensityof(density)) == density
```
"""
function logfuncdensity end
export logfuncdensity

logfuncdensity(log_f) = LogFuncDensity(log_f)

logfuncdensity(log_f::Base.Fix1{typeof(logdensityof)}) = log_f.x


"""
    struct DensityInterface.LogFuncDensity{F}

Wraps a log-density function `log_f` to make it compatible with `DensityInterface`
interface. Typically, `LogFuncDensity(log_f)` should not be called
directly, [`logfuncdensity`](@ref) should be used instead.
"""
struct LogFuncDensity{F}
    _log_f::F
end
LogFuncDensity

@inline hasdensity(::LogFuncDensity) = true

@inline logdensityof(density::LogFuncDensity, x) = density._log_f(x)
@inline logdensityof(density::LogFuncDensity) = density._log_f

function Base.show(io::IO, density::LogFuncDensity)
    print(io, Base.typename(typeof(density)).name, "(")
    show(io, density._log_f)
    print(io, ")")
end



"""
    densityof(d, x)::Real
    densityof(d)

Computes the density value of `d` at a given point `x`, resp.
returns a function that does so:

```julia
densityof(some_density, x) == exp(logdensityof(some_density, x))
densityof(some_density, x) == densityof(some_density)(x)
```

and

```julia
f = densityof(density)
f(x) == densityof(density, x)
```

`densityof(density)` defaults to `exp(logdensityof(density))`, but
may be specialized for specific density-like types.

`densityof(density)` defaults to `Base.Fix1(densityof, density)`, but
may be specialized for specific density-like types.

See also [`densityof`](@ref).
"""
densityof(d, x) = exp(logdensityof(d, x))
export densityof

function densityof(density)
    check_hasdensity(density)
    Base.Fix1(densityof, density)
end
