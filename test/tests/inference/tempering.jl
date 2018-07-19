using Omega
using UnicodePlots

"Test equality of random variables"
function simpleeq(ALG)
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  diff = abs(x - y)
  β = kumaraswamy(0.1, 5.0)
  k = Omega.kf1β(β)
  n = 10000
  ΩT = SimpleΩ{Int, Float64}
  samples = rand(ΩT, ≊(x, y, k), ALG;
                 n = n,
                 cb = [Omega.default_cbs(n);
                       throttle(Omega.plotrv(β, "Temperature: β"), 1);
                       throttle(Omega.plotω(x, y), 1);
                       throttle(Omega.plotrv(diff, "||x - y||"), 1)])
end

"Test equality of random variables"
function simpleeq(ALG)
  x = normal(0.0, 1.0)
  y = normal(0.0, 1.0)
  diff = abs(x - y)
  β = Omega.d(x, y)
  k = Omega.kf1β(β)
  n = 5000000
  ΩT = SimpleΩ{Int, Float64}
  samples = rand(ΩT, ≊(x, y, k), ALG;
                 n = n,
                 cb = [Omega.default_cbs(n);
                       throttle(Omega.plotrv(β, "Temperature: β"), 1);
                       throttle(Omega.plotω(x, y), 1);
                       throttle(Omega.plotrv(diff, "||x - y||"), 1)])
end

"Test equality of random variables"
function simpleeq(ALG)
  x = normal(0.0, 1.0) 
  y = normal(0.0, 1.0)
  diff = abs(x - y)
  k = Omega.kpow
  k = Omega.kpareto2
  k = Omega.burr
  n = 5000000
  ΩT = SimpleΩ{Int, Float64}
  samples = rand(ΩT, Omega.ueq(x, y, k), ALG;
                 stepsize=0.0001,
                 n = n,
                 cb = [Omega.default_cbs(n);
                      #  throttle(Omega.plotrv(β, "Temperature: β"), 1);
                       throttle(Omega.plotω(x, y), 1);
                       throttle(Omega.plotrv(diff, "||x - y||"), 1)])
end