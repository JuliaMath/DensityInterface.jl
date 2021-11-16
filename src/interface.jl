# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).


"""
    struct IsDensity end

As a return value of [`densitykind(object)`](@ref), indicates that
`object` *is* (represents) a density, like a probability density
object.

See also [`logdensityof`](@ref) and [`densityof`](@ref).
"""
struct IsDensity end
export IsDensity

"""
    struct HasDensity end

As a return value of [`densitykind(object)`](@ref), indicates that
`object` *has* a density, like a probability distribution has
a probability density.

See also [`logdensityof`](@ref) and [`densityof`](@ref).
"""
struct HasDensity end
export HasDensity

"""
    IsOrHasDensity = Union{IsDensity, HasDensity}

As a return value of [`densitykind(object)`](@ref), indicates that `object`
either *is* or *has* a density, as understood by `DensityInterface`.

See also [`IsDensity`](@ref) and [`IsDensity`](@ref).
"""
const IsOrHasDensity = Union{IsDensity, HasDensity}
export IsOrHasDensity

"""
    struct NoDensity end

As a return value of [`densitykind(object)`](@ref), indicates that
`object` *is not* and *does not have* a density, as understood by
`DensityInterface`.
"""
struct NoDensity end
export NoDensity

"""
    DensityKind = Union{IsOrHasDensity, NoDensity}

As a return value of [`densitykind(object)`](@ref), indicates that
`object` is, resp. has, a density or that `object` is not
associated with a density.

See also [`IsOrHasDensity`](@ref) and [`NoDensity`](@ref).
"""
const DensityKind = Union{IsOrHasDensity, NoDensity}
export DensityKind


"""
    densitykind(object)::DensityKind

Tell if `object` *is* a density or if it *has* a density, in the sense of the
`DensityInterface` API, or if is *not* associated with a density.
    
Return either `IsDensity()`, `HasDensity()` or `NoDensity()`

In addition to [`IsDensity`](@ref), [`HasDensity`](@ref) or [`NoDensity`](@ref),
two unions

* `IsOrHasDensity = Union{IsDensity, HasDensity}`
* `DensityKind = Union{IsOrHasDensity, NoDensity}`

are defined for convenience. `densitykind(object) isa IsOrHasDensity` implies
that `object` is either a density itself or can be said to have an associated
density. It also implies that the value of that density at given points can be
calculated via [`logdensityof`](@ref) and [`densityof`](@ref).

Defaults to `NoDensity()`. For a type that *is* (directly represents)
a density, like a probability density, define

```julia
@inline densitykind(::MyDensityType) = IsDensity()
```

For a type that *has* (is associated with) a density in some way, like
a probability distribution has a probability density, define

```julia
@inline densitykind(::MyDensityType) = HasDensity()
```
"""
function densitykind end
export densitykind

@inline densitykind(object) = NoDensity()


function _check_is_or_has_density(object)
    densitykind(object) isa IsOrHasDensity || throw(ArgumentError("Object of type $(typeof(object)) neither is nor has a density"))
end


"""
    logdensityof(object, x)::Real

Compute the logarithmic value of the density `object` (resp. its associated density)
at a given point `x`.

```jldoctest a
julia> densitykind(object)
IsDensity()

julia> logy = logdensityof(object, x); logy isa Real
true
```

See also [`densitykind`](@ref) and [`densityof`](@ref).
"""
function logdensityof end
export logdensityof

"""
    logdensityof(object)

Return a function that computes the logarithmic value of the density `object`
(resp. its associated density) at a given point.

```jldoctest a
julia> log_f = logdensityof(object); log_f isa Function
true

julia> log_f(x) == logdensityof(object, x)
true
```

`logdensityof(object)` defaults to `Base.Fix1(logdensityof, object)`, but may be
specialized. If so, [`logfuncdensity`](@ref) will typically have to be
specialized for the return type of `logdensityof` as well.

[`logfuncdensity`](@ref) is the inverse of `logdensityof`, so
`logfuncdensity(log_f)` must be equivalent to `object`.
"""
function logdensityof(object)
    _check_is_or_has_density(object)
    Base.Fix1(logdensityof, object)
end


"""
    densityof(object, x)::Real

Compute the value of the density `object` (resp. its associated density)
at a given point `x`.
    
```jldoctest a
julia> densitykind(object)
IsDensity()

julia> densityof(object, x) == exp(logdensityof(object, x))
true
```

`densityof(object, x)` defaults to `exp(logdensityof(object, x))`, but
may be specialized.

See also [`densitykind`](@ref) and [`densityof`](@ref).
"""
densityof(object, x) = exp(logdensityof(object, x))
export densityof

"""
    densityof(object)

Return a function that computes the value of the density `object`
(resp. its associated density) at a given point.
        
```jldoctest a
julia> f = densityof(object);

julia> f(x) == densityof(object, x)
true
```

`densityof(object)` defaults to `Base.Fix1(densityof, object)`, but may be specialized.
"""
function densityof(object)
    _check_is_or_has_density(object)
    Base.Fix1(densityof, object)
end



"""
    logfuncdensity(log_f)

Return a `DensityInterface`-compatible density that is defined by a given
log-density function `log_f`:

```jldoctest
julia> object = logfuncdensity(log_f);

julia> densitykind(object)
IsDensity()

julia> logdensityof(object, x) == log_f(x)
true
```

`logfuncdensity(log_f)` returns an instance of [`DensityInterface.LogFuncDensity`](@ref)
by default, but may be specialized to return something else depending on the
type of `log_f`). If so, [`logdensityof`](@ref) will typically have to be
specialized for the return type of `logfuncdensity` as well.

`logfuncdensity` is the inverse of `logdensityof`, so the following must
hold true:

* `d = logfuncdensity(logdensityof(object))` is equivalent to `object` in
  respect to `logdensityof` and `densityof`. However, `d` may not be equal to
  `object`, especially if `densitykind(object) == HasDensity()`: `logfuncdensity` always
  creates something that *is* density, never something that just *has*
  a density in some way (like a distribution or a measure in general).
* `logdensityof(logfuncdensity(log_f))` is equivalent (typically equal or even
  identical to) to `log_f`.

See also [`densitykind`](@ref).
"""
function logfuncdensity end
export logfuncdensity

@inline logfuncdensity(log_f) = LogFuncDensity(log_f)

# For functions stemming from objects that *have* a density, create a new density:
@inline _logfuncdensity_impl(::HasDensity, log_f::Base.Fix1{typeof(logdensityof)}) = LogFuncDensity(log_f)
# For functions stemming from objects that *are* a density, recover original object:
@inline _logfuncdensity_impl(::IsDensity, log_f::Base.Fix1{typeof(logdensityof)}) = log_f.x

@inline logfuncdensity(log_f::Base.Fix1{typeof(logdensityof)}) = _logfuncdensity_impl(densitykind(log_f.x), log_f)

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

@inline densitykind(::LogFuncDensity) = IsDensity()

@inline logdensityof(object::LogFuncDensity, x) = object._log_f(x)
@inline logdensityof(object::LogFuncDensity) = object._log_f

@inline densityof(object::LogFuncDensity, x) = exp(object._log_f(x))
@inline densityof(object::LogFuncDensity) = exp ∘ object._log_f

function Base.show(io::IO, object::LogFuncDensity)
    print(io, nameof(typeof(object)), "(")
    show(io, object._log_f)
    print(io, ")")
end



"""
    funcdensity(f)

Return a `DensityInterface`-compatible density that is defined by a given
non-log density function `f`:

```jldoctest
julia> object = funcdensity(f);

julia> densitykind(object)
IsDensity()

julia> densityof(object, x) == f(x)
true
```

`funcdensity(f)` returns an instance of [`DensityInterface.FuncDensity`](@ref)
by default, but may be specialized to return something else depending on the
type of `f`). If so, [`densityof`](@ref) will typically have to be
specialized for the return type of `funcdensity` as well.

`funcdensity` is the inverse of `densityof`, so the following must
hold true:

* `d = funcdensity(densityof(object))` is equivalent to `object` in
  respect to `logdensityof` and `densityof`. However, `d` may not be equal to
  `object`, especially if `densitykind(object) == HasDensity()`: `funcdensity` always
  creates something that *is* density, never something that just *has*
  a density in some way (like a distribution or a measure in general).
* `densityof(funcdensity(f))` is equivalent (typically equal or even
  identical to) to `f`.

See also [`densitykind`](@ref).
"""
function funcdensity end
export funcdensity

@inline funcdensity(f) = FuncDensity(f)

# For functions stemming from objects that *have* a density, create a new density:
@inline _funcdensity_impl(::HasDensity, f::Base.Fix1{typeof(densityof)}) = FuncDensity(f)
# For functions stemming from objects that *are* a density, recover original object:
@inline _funcdensity_impl(::IsDensity, f::Base.Fix1{typeof(densityof)}) = f.x

@inline funcdensity(f::Base.Fix1{typeof(densityof)}) = _funcdensity_impl(densitykind(f.x), f)

InverseFunctions.inverse(::typeof(funcdensity)) = densityof
InverseFunctions.inverse(::typeof(densityof)) = funcdensity


"""
    struct DensityInterface.FuncDensity{F}

Wraps a non-log density function `f` to make it compatible with
`DensityInterface` interface. Typically, `FuncDensity(f)` should not be
called directly, [`funcdensity`](@ref) should be used instead.
"""
struct FuncDensity{F}
    _f::F
end
FuncDensity

@inline densitykind(::FuncDensity) = IsDensity()

@inline logdensityof(object::FuncDensity, x) = log(object._f(x))
@inline logdensityof(object::FuncDensity) = log ∘ object._f

@inline densityof(object::FuncDensity, x) = object._f(x)
@inline densityof(object::FuncDensity) = object._f

function Base.show(io::IO, object::FuncDensity)
    print(io, nameof(typeof(object)), "(")
    show(io, object._f)
    print(io, ")")
end
