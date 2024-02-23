## Progressive Evolutionary Structural Optimisation (PESO) algorithm for thermal science

This is an improvement of the [ESO (Evolutionary Structural Optimisation)](https://github.com/Raphael-Boichot/Evolutionary-structural-optimisation-algorithm) that was suggested in 2006 by [Lingai Luo](https://scholar.google.fr/citations?user=2Q79jugAAAAJ&hl=fr), my post-doctoral supervisor, so quite long ago, but never immplemented to my knowledge. The idea is to use very coarse geometry first and to refine progressively the domain meshing in order to fasten the convergence. The principle works great but has the flaw of its main advantage: going fast increases the probability to fall into a local optimum. 

Overall this code converges much faster than the "regular" ESO algorithm (Globally 10x faster) but the topology obtained are a bit more coarse and less fibrous. This implies that they are less efficient but also that they are easier to fabricate. Anyway, enjoy the code !
