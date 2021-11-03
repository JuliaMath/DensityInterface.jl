# DensityInterface.jl

```@docs
DensityInterface
```

This package defines an interface for mathematical/statistical densities and objects associated with a density in Julia. The interface comprises the functions [`hasdensity`](@ref),  [`logdensityof`](@ref)/[`densityof`](@ref) and [`logfuncdensity`](@ref).

The following methods must be provided to make a type (e.g. `SomeDensity`) compatible with the interface:

```julia
import DensityInterface

DensityInterface.hasdensity(::SomeDensity) = true
DensityInterface.logdensityof(d::SomeDensity, x) = log_of_d_at_x
```

The object `d` may be a density itself or something that can be said to have a density. If `d` is a distribution, the density is the PDF. If `d` is a measure in general, it's density is implied here to be the Radon–Nikodym derivative of `d` and it's base measure. In statistical inference applications, for example, `d` might be a likelihood, prior or posterior.

Note: The package [`MeasureTheory`](https://github.com/cscherrer/MeasureTheory.jl) provides tools to work with densities and measures that go beyond the density in respect to an implied base measure.

DensityInterface includes a default implementation of a density defined by a log-density function. It provides a convenient way of passing a log-density function to algorithms like optimizers, samplers, etc.:

```julia
using DensityInterface

d = SomeDensity()
log_f = logdensityof(d)
log_f(x) == logdensityof(d, x)

SomeOptimizerPackage.maximize(logdensityof(d), x_init)
```

Reversely, a given log-density function `log_f` can be converted to a
DensityInterface-compatible density object using [`logfuncdensity`](@ref):

```julia
d = logfuncdensity(log_f)
hasdensity(d) == true
logdensityof(d, x) == log_f(x)
```
