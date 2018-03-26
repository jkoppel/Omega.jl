## Sampling and Inference
## ======================
"Unconditional Sample from `x`"
Base.rand(x::RandVar) = x(Omega())

"Sample from `x | y == true` with rejection sampling"
function Base.rand(x::RandVar, y::RandVar{Bool}, alg::Type{RejectionSample})
  while true
    ω = Omega()
    if y(ω)
      return x(ω)
    end
  end
end

"Sample from `x | y == true` with rejection sampling"
function Base.rand(x::RandVar{T}, y::RandVar{SoftBool};
                   n::Integer = 1000, alg::Type{MH} = MH) where T
  ω = Omega()
  plast = y(ω).epsilon
  qlast = 1.0
  samples = T[]
  for i = 1:n
    ω_ = Omega()
    p_ = y(ω_).epsilon
    ratio = p_ / plast
    if rand() < ratio
      ω = ω_
      plast = p_
    end
    push!(samples, x(ω))
  end
  samples
end

"Default rand (rejection sample)"
Base.rand(x, y) = rand(x, y, RejectionSample)
