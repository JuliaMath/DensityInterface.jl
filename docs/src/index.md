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

This package defines an interface for mathematical/statistical densities and objects associated with a density in Julia. The interface comprises the functions [`hasdensity`](@ref),  [`logdensityof`](@ref)/[`densityof`](@ref)[^1] and [`logfuncdensity`](@ref).

The following methods must be provided to make a type (e.g. `SomeDensity`) compatible with the interface:

```jldoctest a
import DensityInterface

DensityInterface.hasdensity(::SomeDensity) = true
DensityInterface.logdensityof(d::SomeDensity, x) = log_of_d_at(x)

DensityInterface.logdensityof(SomeDensity(), x) isa Real

# output

true
```

The object `d` may be a density itself or something that can be said to have a density. If `d` is a distribution, the density is its probability density function. In the measure theoretical sense, the density function is the Radon–Nikodym derivative of `d` with respect to an implicit base measure. In statistical inference applications, for example, `d` might be a likelihood, prior or posterior[^2].

DensityInterface automatically provides `logdensityof(d)`, equivalent to `x -> logdensityof(d, x)`. This constitutes a convenient way of passing a (log-)density function to algorithms like optimizers, samplers, etc.:

```jldoctest a
using DensityInterface

d = SomeDensity()
log_f = logdensityof(d)
log_f(x) == logdensityof(d, x)

# output

true
```

```julia
SomeOptimizerPackage.maximize(logdensityof(d), x_init)
```

Reversely, a given log-density function `log_f` can be converted to a DensityInterface-compatible density object using [`logfuncdensity`](@ref):

```julia
d = logfuncdensity(log_f)
hasdensity(d) == true
logdensityof(d, x) == log_f(x)

# output

true
```


[^1]: The function names `logdensityof` and `densityof` were chosen to convey that the target object may either *be* a density or something that can be said to *have* a density. They also have less naming conflict potential than `logdensity` and esp. `density` (the latter already being exported by Plots.jl).

[^2]: The package [`MeasureTheory`](https://github.com/cscherrer/MeasureTheory.jl) provides tools to work with densities and measures that go beyond the density in 
respect to an implied base measure.
