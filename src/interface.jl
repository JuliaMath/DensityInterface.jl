# This file is a part of DensityInterface.jl, licensed under the MIT License (MIT).


"""
    ismeasure(object)::Bool

Return `true` if `object` is a measure.

!!ToDo: More text!!

Defaults to `false`. For types that are measures (not densities), define

```julia
@inline ismeasure(::MyMeasureType) = true
```

The above will automatically provide `hasdensity(::MyMeasureType) == true`.

See also [`hasdensity`](@ref) and [`isdensity`](@ref).
"""
function ismeasure end
export ismeasure

@inline ismeasure(object) = false


"""
    hasdensity(object)::Bool

Return `true` if `object` is compatible with the `DensityInterface` interface.

`hasdensity(object) == true` implies that `object` is either a density itself or
has an associated density, e.g. a probability density function or a Radon–Nikodym
derivative with respect to an implicit base measure. It also implies that the
value of that density at given points can be calculated via
[`logdensityof`](@ref) and [`densityof`](@ref).

Defaults to `ismeasure(object)`. For types that are densities, not measures,
define

```julia
@inline hasdensity(::MyDensityType) = true
```

See also [`ismeasure`](@ref) and [`isdensity`](@ref).
"""
function hasdensity end
export hasdensity

@inline hasdensity(object) = ismeasure(object)

function check_hasdensity(d)
    hasdensity(d) || throw(ArgumentError("Object of type $(typeof(d)) is not compatible with DensityInterface"))
end


"""
    isdensity(object) = hasdensity(object) && !ismeasure(object)

Return `true` if `object` is a density. Defaults to
`hasdensity(object) && !ismeasure(object)`.

!!ToDo: More text!!

`isdensity` should *not* be specialized, specialize [`ismeasure`](@ref) instead.

See also [`hasdensity`](@ref).
"""
function isdensity end
export isdensity

@inline isdensity(object) = hasdensity(object) && !ismeasure(object)


"""
    basemeasure(m)

Return the base measure of measure `m`.

`logdensityof(m, x)` and `densityof(m, x)` return the log/non-log
Radon–Nikodym derivative of `m` with respect to `basemeasure(m)` evaluated at `x`.

!!ToDo: More text!!
"""
function basemeasure end
export basemeasure


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

* `logfuncdensity(logdensityof(object))` is equivalent to `object` in respect to `logdensityof`.
  However, it may not be equal to `object`, especially if `ismeasure(object) == true`:
  `logfuncdensity` always creates a density, never a measure.
* `logdensityof(logfuncdensity(log_f))` is equivalent  (often equal or even
  identical to) to `log_f`.

See also [`hasdensity`](@ref).
"""
function logfuncdensity end
export logfuncdensity

@inline logfuncdensity(log_f) = LogFuncDensity(log_f)

# For functions stemming from measures create a density, not a measure:
@inline _logfuncdensity_impl(::Val{true}, log_f::Base.Fix1{typeof(logdensityof)}) = LogFuncDensity(log_f)
# For functions stemming from densities recover original density:
@inline _logfuncdensity_impl(::Val{false}, log_f::Base.Fix1{typeof(logdensityof)}) = log_f.x

@inline logfuncdensity(log_f::Base.Fix1{typeof(logdensityof)}) = _logfuncdensity_impl(Val(ismeasure(log_f.x)), log_f)

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

@inline densityof(d::LogFuncDensity, x) = exp(d._log_f(x))
@inline densityof(d::LogFuncDensity) = exp ∘ d._log_f

function Base.show(io::IO, d::LogFuncDensity)
    print(io, nameof(typeof(d)), "(")
    show(io, d._log_f)
    print(io, ")")
end



"""
    funcdensity(f)

Return a `DensityInterface`-compatible density that is defined by a given
non-log density function `f`:

```jldoctest
julia> d = funcdensity(f);

julia> hasdensity(d) == true
true

julia> densityof(d, x) == f(x)
true
```

`funcdensity(f)` returns an instance of [`DensityInterface.FuncDensity`](@ref)
by default, but may be specialized to return something else depending on the
type of `f`). If so, [`densityof`](@ref) will typically have to be
specialized for the return type of `funcdensity` as well.

`funcdensity` is the inverse of `densityof`, so the following must
hold true:

* `funcdensity(densityof(object))` is equivalent to `object` in respect to `densityof`.
  However, it may not be equal to `object`, especially if `ismeasure(object) == true`:
  `funcdensity` always creates a density, never a measure.
* `densityof(funcdensity(f))` is equivalent (often equal or even
  identical to) to `f`.

See also [`hasdensity`](@ref).
"""
function funcdensity end
export funcdensity

@inline funcdensity(f) = FuncDensity(f)

# For functions stemming from measures, create a density (not a measure):
@inline _funcdensity_impl(::Val{true}, f::Base.Fix1{typeof(densityof)}) = FuncDensity(f)
# For functions stemming from densities, recover original density:
@inline _funcdensity_impl(::Val{false}, f::Base.Fix1{typeof(densityof)}) = f.x

@inline funcdensity(f::Base.Fix1{typeof(densityof)}) = _funcdensity_impl(Val(ismeasure(f.x)), f)

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

@inline hasdensity(::FuncDensity) = true

@inline logdensityof(d::FuncDensity, x) = log(d._f(x))
@inline logdensityof(d::FuncDensity) = log ∘ d._f

@inline densityof(d::FuncDensity, x) = d._f(x)
@inline densityof(d::FuncDensity) = d._f

function Base.show(io::IO, d::FuncDensity)
    print(io, nameof(typeof(d)), "(")
    show(io, d._f)
    print(io, ")")
end
