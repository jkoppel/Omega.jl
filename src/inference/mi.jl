"Metropolized Independent Sampling"
struct MIAlg <: Algorithm end

"Metropolized Independent Sampling"
const MI = MIAlg()

isapproximate(::MIAlg) = true

"Sample `ω | y == true` with Metropolis Hasting"
function Base.rand(y::RandVar,
                   n,
                   alg::MIAlg,
                   ΩT::Type{OT};
                   cb = default_cbs(n),
                   hack = true) where {OT <: Ω}
  ω = ΩT()
  xω_, sb = trackerrorapply(y, ω)
  plast = epsilon(sb)
  qlast = 1.0
  ωsamples = ΩT[]
  accepted = 0
  for i = 1:n
    ω_ = ΩT()
    xω_, sb = trackerrorapply(y, ω_)
    p_ = epsilon(sb)
    ratio = p_ / plast
    if rand() < ratio
      ω = ω_
      plast = p_
      accepted += 1
    end
    push!(ωsamples, ω)
    cb(RunData(ω = ω, accepted = accepted, p = p_, i = i), Outside)
  end
  [applywoerror.(y, ω_) for ω_ in ωsamples]
end