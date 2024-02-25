## Progressive Evolutionary Structural Optimisation (PESO) algorithm for thermal science

This is an improvement of the [ESO (Evolutionary Structural Optimisation)](https://github.com/Raphael-Boichot/Evolutionary-structural-optimisation-algorithm) that was suggested in 2006 by [Lingai Luo](https://scholar.google.fr/citations?user=2Q79jugAAAAJ&hl=fr), my post-doctoral supervisor, so quite long ago, but never implemented to my knowledge. The idea is to use very coarse geometry first and to refine progressively the domain meshing in order to fasten the convergence. The principle works great but has the flaw of its main advantage: going fast increases the probability to fall into a local optimum. 

Overall this code converges much faster than the "regular" ESO algorithm (Globally 50x faster) but the topology obtained are a bit more coarse and less fibrous (mathematically, non branched/fibrous shapes are optimal). This implies that they are a bit less efficient but also easier to fabricate. The shapes at convergence are very similar to the [Genetic Algorithm implementation](https://github.com/Raphael-Boichot/A-genetic-algorithm-for-topology-optimization-of-area-to-point-heat-conduction-problem). Anyway, enjoy the code and cite the author !

Some cheats are used to fasten and ease convergence:
- The code starts by assessing 10 random topologies with 10 ESO steps (Monte Carlo stage). This allows avoiding to fall into obvious local minima as the "coarse" epochs kind of determine what the final shape will be, even if thermal resistance between converged shapes are very similar;
- The best topology is always kept in memory as the ESO algorithm does not always improves topology near the global optimum for a given mesh. At the mesh doubling step, the last best known geometry is recalled for faster convergence. So topology can "jitter" at this step, this is intended;
- The maximal number of etch/growth allowed for one cell are progressively increased with mesh refining;
- The redunding boundary cells around the adiabatic/isothermal external borders are discarded at each mesh doubling in order to avoid superfluous calculations;
- Of course only half a domain is considered for calculation. The whole topology is reconstructed by mirroring;

The method has obvious flaws:
- The ESO algorithm tends to focus mainly on the base of the "tree" whatever the hyper parameters I use. Not sure how to fix that without introducing bias. It may just be due to the poor sensitivity of thermal resistance to the conductivity of "terminal" cells;
- Starting from a coarse mesh and refining it leads to more compact shapes at the end. The code falls easily into some local minima.

## Exemple of convergence with kp/k0=10 and filling ratio = 0.3, domain size from 1x to 8x (10 steps per frame)

![PESO algorithm](Pictures/Figure.gif)
