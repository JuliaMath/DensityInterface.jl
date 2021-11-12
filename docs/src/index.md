# DensityInterface.jl

```@meta
DocTestSetup = quote
    struct SomeDensity end
    log_of_d_at(x) = x^2
    x = 4
end
```

```@docs
DensityInterface
```

This package defines an interface for mathematical/statistical densities and objects associated with a density in Julia. The interface comprises the functions [`densitykind`](@ref),  [`logdensityof`](@ref)/[`densityof`](@ref)[^1] and [`logfuncdensity`](@ref)/[`funcdensity`](@ref).

The following methods must be provided to make a type (e.g. `SomeDensity`) compatible with the interface:

```jldoctest a
import DensityInterface

@inline DensityInterface.densitykind(::SomeDensity) = IsDensity()
DensityInterface.logdensityof(object::SomeDensity, x) = log_of_d_at(x)

object = SomeDensity()
DensityInterface.logdensityof(object, x) isa Real

# output

true
```

`object` may be a density itself or something that can be said to have a density. If `object` is a distribution, the density is its probability density function. In the measure theoretical sense, the density function is the Radon–Nikodym derivative of `object` with respect to an implicit base measure. If `object` is not a density itself but has a density in this way, [`densitykind`](@ref) will not return [`IsDensity()`](@ref) but an instance of another subtype of [`IsOrHasDensity`](@ref)[^1].

In statistical inference applications, for example, `object` might be a likelihood, prior or posterior[^2].

DensityInterface automatically provides `logdensityof(object)`, equivalent to `x -> logdensityof(object, x)`. This constitutes a convenient way of passing a (log-)density function to algorithms like optimizers, samplers, etc.:

```jldoctest a
using DensityInterface

object = SomeDensity()
log_f = logdensityof(object)
log_f(x) == logdensityof(object, x)

# output

true
```

```julia
SomeOptimizerPackage.maximize(logdensityof(object), x_init)
```

Reversely, a given log-density function `log_f` can be converted to a DensityInterface-compatible density object using [`logfuncdensity`](@ref):

```julia
object = logfuncdensity(log_f)
densitykind(object) == IsDensity() && logdensityof(object, x) == log_f(x)

# output

true
```


[^1]: The function names `logdensityof` and `densityof` were chosen to convey that the target object may either *be* a density or something that can be said to *have* a density. They also have less naming conflict potential than `logdensity` and esp. `density` (the latter already being exported by Plots.jl).

[^2]: The packages [`MeasureBase`](https://github.com/cscherrer/MeasureBase.jl) and [`MeasureTheory`](https://github.com/cscherrer/MeasureTheory.jl) provide tools to work with densities and measures that go beyond the density in respect to an implied base measure.
