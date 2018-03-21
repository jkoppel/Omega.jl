abstract type AbstractRandVar{T} end

"Random Variable `Ω -> T`"
struct RandVar{T} <: AbstractRandVar{T}
  f::Function
  ωids::Set{Int}
end

"Random Variable `Ω_i -> T`"
RandVar{T}(f::Function, i::Int) where T = RandVar{T}(f, Set(i))

"`x(ω)`"
(x::RandVar)(ω::Omega) = x.f(ω)

"All dimensions of `ω` that `x` draws from"
ωids(x::RandVar) = x.ωids
ωids(x) = Set{Int}() # Non RandVars defaut to emptyset (convenience)

apl(x::Real, ω::Omega) = x
apl(x::RandVar, ω::Omega) = x(ω)

## Primitive Distributions
"`uniform(a, b)`"
function uniform(a, b, ω::Omega, ωid=ωnew())
  ω[ωid] * (b - a) + a
end

uniform(a, b, ωid=ωnew()) =
  RandVar{Real}(ω -> uniform(a, b, ω, ωid), ωid)

normal(μ, σ, ω::Omega, ωid::Int) = quantile(Normal(μ, σ), ω[ωid])
function normal(μ, σ, ωid::Int=ωnew())
  @show union(Set(ωid), ωids(μ), ωids(σ))
  RandVar{Real}(ω -> normal(apl(μ, ω), apl(σ, ω), ω, ωid),
                union(Set(ωid), ωids(μ), ωids(σ)))
end

# normal(μ, σ, ω::Omega, ωid::Int) = lift(normal, μ, σ, ω, ωid)

## Functions
## =========
struct Interval
  a
  b
end

Base.in(x, ab::Interval) = x >= ab.a && x <= ab.b
Base.in(x::RandVar, ab::Interval) = RandVar{Bool}(ω -> x(ω) ∈ ab, ωids(x))

## Sampling and Inference
## ======================
"Unconditional Sample from `x`"
Base.rand(x::RandVar) = x(Omega())

"Sample from `x | y == true` with rejection sampling"
function Base.rand(x::RandVar, y::RandVar{Bool})
  while true
    ω = Omega()
    if y(ω)
      return x(ω)
    end
  end
end

"Sample from `x | y == true` with rejection sampling"
function Base.rand(x::RandVar, y::RandVar{SoftBool})
  ω = Omega()
  (ω, x(ω), y(ω).epsilon)
end

## Functions of Random Variables
## =============================
"Expectation of `x`"
expectation(x::RandVar{Real}, n=1000) = sum((rand(x) for i = 1:n)) / n
expectation(x::RandVar{RandVar{Real}}, n=1000) =
  RandVar{Real}(ω -> expectation(x(ω), n), ωids(x))

"Project `y` onto the randomness of `x` *the magic*

```jldoctest
p = uniform(0.1, 0.9)
X = Bernoulli(p)
y = normal(x, 1)
[rand(expectation(curry(y, x))) for _ = 1:10]
[rand(expectation(curry(y, p))) for _ = 1:10]
```
"
function curry(y::RandVar{T}, x::RandVar) where T
  RandVar{RandVar{T}}(ω1 -> let ω_ = project(ω1, ωids(x))
                              RandVar{T}(ω2 -> y(merge(ω2, ω_)), ωids(y))
                            end,
                      ωids(x))
end

softeq(x::RandVar{Real}, y::Real) = RandVar{SoftBool}(ω -> SoftBool(1 - f1((x(ω) - y)^2)), ωids(x))
Base.:&(x::RandVar{SoftBool}, y::RandVar{SoftBool}) =
  RandVar{SoftBool}(ω -> SoftBool(min(x(ω).epsilon, y(ω).epsilon)),
                   union(ωids(x), ωids(y)))