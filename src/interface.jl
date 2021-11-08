# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).


"""
    hasdensity(d)::Bool

Return `true` if `d` is compatible with the `DensityInterface` interface.

`hasdensity(d) == true` implies that `d` is either a density itself or has an
associated density, e.g. a probability density function or a Radon–Nikodym
derivative with respect to an implicit base measure. It also implies that the
value of that density at given points can be calculated via
[`logdensityof`](@ref) and [`densityof`](@ref).
```
"""
function hasdensity end
export hasdensity

@inline hasdensity(::Any) = false

function check_hasdensity(d)
    hasdensity(d) || throw(ArgumentError("Object of type $(typeof(d)) is not compatible with DensityInterface"))
end


"""
    logdensityof(d, x)::Real

Compute the logarithmic value of density `d` or it's associated density
at a given point `x`.

```jldoctest a
julia> hasdensity(d)
true

julia> logy = logdensityof(d, x); logy isa Real
true
```

See also [`hasdensity`](@ref) and [`densityof`](@ref).
"""
function logdensityof end
export logdensityof

"""
    logdensityof(d)

Return a function that computes the logarithmic value of density `d`
or its associated density at a given point.

```jldoctest a
julia> log_f = logdensityof(d); log_f isa Function
true

julia> log_f(x) == logdensityof(d, x)
true
```

`logdensityof(d)` defaults to `Base.Fix1(logdensityof, d)`, but may be
specialized. If so, [`logfuncdensity`](@ref) will typically have to be
specialized for the return type of `logdensityof` as well.

[`logfuncdensity`](@ref) is the inverse of `logdensityof`, so
`logfuncdensity(log_f)` must be equivalent to `d`.
"""
function logdensityof(d)
    check_hasdensity(d)
    Base.Fix1(logdensityof, d)
end


"""
    logfuncdensity(log_f)

Return a `DensityInterface`-compatible density that is defined by a given
log-density function `log_f`:

```jldoctest
julia> d = logfuncdensity(log_f);

julia> hasdensity(d) == true
true

julia> logdensityof(d, x) == log_f(x)
true
```

`logfuncdensity(log_f)` returns an instance of [`DensityInterface.LogFuncDensity`](@ref)
by default, but may be specialized to return something else depending on the
type of `log_f`). If so, [`logdensityof`](@ref) will typically have to be
specialized for the return type of `logfuncdensity` as well.

`logfuncdensity` is the inverse of `logdensityof`, so the following must
hold true:

* `logfuncdensity(logdensityof(d))` is equivalent to `d`
* `logdensityof(logfuncdensity(log_f))` is equivalent to `log_f`.

See also [`hasdensity`](@ref).
"""
function logfuncdensity end
export logfuncdensity

logfuncdensity(log_f) = LogFuncDensity(log_f)

logfuncdensity(log_f::Base.Fix1{typeof(logdensityof)}) = log_f.x

InverseFunctions.inverse(::typeof(logfuncdensity)) = logdensityof
InverseFunctions.inverse(::typeof(logdensityof)) = logfuncdensity


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
    print(io, nameof(typeof(d)), "(")
    show(io, d._log_f)
    print(io, ")")
end



"""
    densityof(d, x)::Real

Compute the value of density `d` or its associated density at a given point
`x`.

```jldoctest a
julia> hasdensity(d)
true

julia> densityof(d, x) == exp(logdensityof(d, x))
true
```

`densityof(d, x)` defaults to `exp(logdensityof(d, x))`, but
may be specialized.

See also [`hasdensity`](@ref) and [`logdensityof`](@ref).
"""
densityof(d, x) = exp(logdensityof(d, x))
export densityof

"""
    densityof(d)

Return a function that computes the value of density `d` or its associated
density at a given point.

```jldoctest a
julia> f = densityof(d);

julia> f(x) == densityof(d, x)
true
```

`densityof(d)` defaults to `Base.Fix1(densityof, d)`, but may be specialized.
"""
function densityof(d)
    check_hasdensity(d)
    Base.Fix1(densityof, d)
end
