# Parallel Poisson Solver

[Handmade Network project page](https://handmade.network/p/588/parallel-poisson-solver/)

A while back, I was making a fluid simulator, and I needed a Poisson solver.
As I was working in an array language at the time ([uiua](www.uiua.org)),
I started thinking about how I would make something like that with an eye on parallel processing,
and I came up with a fun technique for it. However, I never ended up testing the actual characteristics
of the technique with respect to 'known' techniques. (for example: how fast it converges to a solution)

So, for this year's [Wheel Reinvention Jam](https://handmade.network/jam/wheel-reinvention-2024)
I am going to reimplement the algorithm in a systems language,
and for the GPU, to get some proper data on how fast (and maybe useful) it can be.
With this, I'll also make some proper documentation, so that people can follow along somewhat!
