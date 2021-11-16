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

This package defines an interface for mathematical/statistical densities and objects associated with a density in Julia. The interface comprises the type [`DensityKind`](@ref) and the functions [`logdensityof`](@ref)/[`densityof`](@ref)[^1] and [`logfuncdensity`](@ref)/[`funcdensity`](@ref).

The following methods must be provided to make a type (e.g. `SomeDensity`) compatible with the interface:

```jldoctest a
import DensityInterface

@inline DensityInterface.DensityKind(::SomeDensity) = IsDensity()
DensityInterface.logdensityof(object::SomeDensity, x) = log_of_d_at(x)

object = SomeDensity()
DensityInterface.logdensityof(object, x) isa Real

# output

true
```

`object` may be/represent a density itself (`DensityKind(object) === IsDensity()`) or it may be something that can be said to have a density (`DensityKind(object) === HasDensity()`)[^2].

In statistical inference applications, for example, `object` might be a likelihood, prior or posterior.

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
DensityKind(object) === IsDensity() && logdensityof(object, x) == log_f(x)

# output

true
```


[^1]: The function names `logdensityof` and `densityof` were chosen to convey that the target object may either *be* a density or something that can be said to *have* a density. They also have less naming conflict potential than `logdensity` and esp. `density` (the latter already being exported by Plots.jl).

[^2]: The package [`Distributions`](https://github.com/JuliaStats/Distributions.jl) supports `DensityInterface` for `Distributions.Distribution`.
