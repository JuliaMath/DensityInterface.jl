# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).


"""
    isdensity(d)::Bool

Return `true` if `d` is a density.

`isdensity(d) == true` means that `d` itself is/represents a density. It also
implies that the value of the density `d` at given points can be calculated
via [`logdensityof`](@ref) and [`densityof`](@ref).

Defaults to `false`. For types that are/represent a density, define

```julia
@inline isdensity(::MyType) = true
```

`isdensity` and [`hasdensity`](@ref) *must not* both return true for the
same object.
"""
function isdensity end
export isdensity

@inline isdensity(::Any) = false


"""
    hasdensity(object)::Bool

Return `true` if `d` has a density.

`hasdensity(object) == true` means that `d` can be said to have an associated
density. It also implies that the value of that density at given points can
be calculated via [`logdensityof`](@ref) and [`densityof`](@ref).
```

Defaults to `false`. For types that can be said to have a density, define

```julia
@inline hasdensity(::MyType) = true
```

`hasdensity` and [`isdensity`](@ref) *must not* both return true for the
same object.
"""
function hasdensity end
export hasdensity

@inline hasdensity(::Any) = false


function _check_is_or_has_density(d)
    (isdensity(d) ⊻ hasdensity(d)) || throw(ArgumentError("Object of type $(typeof(d)) is not compatible with DensityInterface"))
end


"""
    logdensityof(object, x)::Real

Compute the logarithmic value of the density `object` (resp. its associated density)
at a given point `x`.

```jldoctest a
julia> isdensity(object) ⊻ hasdensity(object)
true

julia> logy = logdensityof(object, x); logy isa Real
true
```

See also [`isdensity`](@ref), [`hasdensity`](@ref) and [`densityof`](@ref).
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
julia> isdensity(object) ⊻ hasdensity(object)
true

julia> densityof(object, x) == exp(logdensityof(object, x))
true
```

`densityof(object, x)` defaults to `exp(logdensityof(object, x))`, but
may be specialized.

See also [`isdensity`](@ref), [`hasdensity`](@ref) and [`densityof`](@ref).
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

julia> isdensity(object)
true

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
  `object`, especially if `hasdensity(object)`: `logfuncdensity` always
  creates something that *is* density, never something that just *has*
  a density in some way (like a distribution or a measure in general).
* `logdensityof(logfuncdensity(log_f))` is equivalent (typically equal or even
  identical to) to `log_f`.

See also [`isdensity`](@ref) and  [`hasdensity`](@ref).
"""
function logfuncdensity end
export logfuncdensity

@inline logfuncdensity(log_f) = LogFuncDensity(log_f)

# For functions stemming from objects that *have* a density, create a new density:
@inline _logfuncdensity_impl(::Val{false}, log_f::Base.Fix1{typeof(logdensityof)}) = LogFuncDensity(log_f)
# For functions stemming from objects that *are* a density, recover original object:
@inline _logfuncdensity_impl(::Val{true}, log_f::Base.Fix1{typeof(logdensityof)}) = log_f.x

@inline logfuncdensity(log_f::Base.Fix1{typeof(logdensityof)}) = _logfuncdensity_impl(Val(isdensity(log_f.x)), log_f)

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

@inline isdensity(::LogFuncDensity) = true

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
-density function `f`:

```jldoctest
julia> object = funcdensity(f);

julia> isdensity(object)
true

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
  `object`, especially if `hasdensity(object)`: `funcdensity` always
  creates something that *is* density, never something that just *has*
  a density in some way (like a distribution or a measure in general).
* `densityof(funcdensity(f))` is equivalent (typically equal or even
  identical to) to `f`.

See also [`isdensity`](@ref) and  [`hasdensity`](@ref).
"""
function funcdensity end
export funcdensity

@inline funcdensity(f) = FuncDensity(f)

# For functions stemming from objects that *have* a density, create a new density:
@inline _funcdensity_impl(::Val{false}, f::Base.Fix1{typeof(densityof)}) = FuncDensity(f)
# For functions stemming from objects that *are* a density, recover original object:
@inline _funcdensity_impl(::Val{true}, f::Base.Fix1{typeof(densityof)}) = f.x

@inline funcdensity(f::Base.Fix1{typeof(densityof)}) = _funcdensity_impl(Val(isdensity(f.x)), f)

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

@inline isdensity(::FuncDensity) = true

@inline logdensityof(object::FuncDensity, x) = log(object._f(x))
@inline logdensityof(object::FuncDensity) = log ∘ object._f

@inline densityof(object::FuncDensity, x) = object._f(x)
@inline densityof(object::FuncDensity) = object._f

function Base.show(io::IO, object::FuncDensity)
    print(io, nameof(typeof(object)), "(")
    show(io, object._f)
    print(io, ")")
end
