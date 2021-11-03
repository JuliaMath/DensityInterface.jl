# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).


"""
    hasdensity(d)::Bool

Returns `true` if `d` is compatible with the `DensityInterface` interface.

`hasdensity(d) == true` implies that `d` is either a density itself or has an
associated density, e.g. a PDF or a Radon–Nikodym derivative with an implied
base measure. Also implies that the value of that density at given points can
be calculated via [`logdensityof`](@ref) and [`densityof`](@ref).
"""
function hasdensity end
export hasdensity

@inline hasdensity(::Any) = false

function check_hasdensity(d)
    hasdensity(d) || throw("Object of type $(typeof(d)) is not compatible with DensityInterface")
end


"""
    logdensityof(d, x)::Real
    logdensityof(d)

Computes the logarithmic value of density `d` or it's associated density
at a given point `x`, resp. returns a function that does so:

```julia
hasdensity(d) == true
logy = logdensityof(d, x)
logdensityof(d, x) == logdensityof(d)(x)
```

and

```julia
log_f = logdensityof(d)
log_f(x) == logdensityof(d, x)
logfuncdensity(log_f) == d
```

`logdensityof(d)` defaults to `Base.Fix1(logdensityof, d)`, but may be
specialized. If so, [`logfuncdensity`](@ref) will typically have to be
specialized for the return type of `logdensityof` as well.
    
The following identity must always hold:

```julia
logfuncdensity(logdensityof(d)) == d
```

See also [`hasdensity`](@ref) and [`densityof`](@ref).
"""
function logdensityof end
export logdensityof

function logdensityof(d)
    check_hasdensity(d)
    Base.Fix1(logdensityof, d)
end


"""
    logfuncdensity(log_f)

Returns a `DensityInterface`-compatible density that is defined by a given
log-density function `log_f`:

```julia
d = logfuncdensity(log_f)
logdensityof(d, x) == log_f(x)
logdensityof(d) == log_f
```

`logfuncdensity(log_f)` returns an instance of [`DensityInterface.LogFuncDensity`](@ref)
by default, but may be specialized to return something else depending on the
type of `log_f`). If so, [`logdensityof`](@ref) will typically have to be
specialized for the return type of `logfuncdensity` as well.
    
The following identity must always hold:

```julia
logfuncdensity(logdensityof(d)) == d
```

See also [`hasdensity`](@ref).
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

@inline logdensityof(d::LogFuncDensity, x) = d._log_f(x)
@inline logdensityof(d::LogFuncDensity) = d._log_f

function Base.show(io::IO, d::LogFuncDensity)
    print(io, Base.typename(typeof(d)).name, "(")
    show(io, d._log_f)
    print(io, ")")
end



"""
    densityof(d, x)::Real
    densityof(d)

Computes the value of density `d` or it's associated density, resp. returns a
function that does so:

```julia
hasdensity(d) == true
densityof(d, x) == exp(logdensityof(d, x))
densityof(d, x) == densityof(d)(x)
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

See also [`hasdensity`](@ref) and [`logdensityof`](@ref).
"""
densityof(d, x) = exp(logdensityof(d, x))
export densityof

function densityof(d)
    check_hasdensity(d)
    Base.Fix1(densityof, d)
end
