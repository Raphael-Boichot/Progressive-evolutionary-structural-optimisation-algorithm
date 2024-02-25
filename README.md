## Progressive Evolutionary Structural Optimisation (PESO) algorithm for thermal science

This is an improvement of the [ESO (Evolutionary Structural Optimisation)](https://github.com/Raphael-Boichot/Evolutionary-structural-optimisation-algorithm) that was suggested in 2006 by [Lingai Luo](https://scholar.google.fr/citations?user=2Q79jugAAAAJ&hl=fr), my post-doctoral supervisor, so quite long ago, but never implemented to my knowledge. The idea is to use very coarse geometry first and to refine progressively the domain meshing in order to fasten the convergence. The principle works great but has the flaw of its main advantage: going fast increases the probability to fall into a local optimum. 

Overall this code converges much faster than the "regular" ESO algorithm (Globally 10x faster) but the topology obtained are a bit more coarse and less fibrous (mathematically, non branched/fibrous shapes are optimal). This implies that they are a bit less efficient but also easier to fabricate. The shapes at convergence are very similar to the [Genetic Algorithm implementation](https://github.com/Raphael-Boichot/A-genetic-algorithm-for-topology-optimization-of-area-to-point-heat-conduction-problem). Anyway, enjoy the code and cite the author !

## Exemple of convergence with kp/k0=10 and filling ratio = 0.3, domain size from 1x to 8x (10 steps per frame)

![PESO algorithm](Pictures/Figure.gif)
