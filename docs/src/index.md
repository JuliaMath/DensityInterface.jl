# DensityInterface.jl

This package defines an interface for mathematical/statistical densities in Julia. The interface comprises the functions [`hasdensity`](@ref),  [`logdensityof`](@ref) and [`logfuncdensity`](@ref).

The following methods must be provided to make a type (e.g. `SomeDensity`) compatible with the interface:

```julia
import DensityInterface

DensityInterface.hasdensity(::SomeDensity) = true
DensityInterface.logdensityof(density::SomeDensity, x) = log_of_density_at_x
```

DensityInterface includes a default implementation of `logdensityof(density)`. It provides a convenient way of passing a log-density function to algorithms like optimizers, samplers, etc.:

```julia
using DensityInterface

density = SomeDensity()
log_f = logdensityof(density)
log_f(x) == logdensityof(density, x)

SomeOptimizerPackage.maximize(logdensityof(density), x_init)
```

Reversely, a given log-density function `log_f` can be converted to a DensityInterface-compatible density object using [`logfuncdensity`](@ref):

```julia
density = logfuncdensity(log_f)
```

The following must always hold true:

```julia
logfuncdensity(logdensityof(density)) == density
logdensityof(logfuncdensity(log_f)) == log_f
```
