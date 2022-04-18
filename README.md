# plant_invasions

Code for "Fewer but higher quality of pollinator visits determines plant invasion success in simulated plant-pollinator networks".

As described in the paper, this experiment simulates the introduction of a single invasive plant species into a stable plant-pollinatior network. We analyze which characteristics of invasive species are most advantageous for their establishment in native communities and what is the effect of species invsions on the network's quantitative visitation structure. 

Included are 1200 predefined networks generated through Thebalt and Fontain's stochastic algorithm. These are composed of three groups of 400 network centered on three points along the empirical species richness and connectance relationship (details here).

## Simulating species invasions

To perform a species invasion, run ```run(networks).m``` in matlab with the range of neworks you want to perform the simulation on as an input. To limit computational runtime, species invasions are only performed with the parameter values on which we based our results: 
* Mortality case 3 (where plants and animals have a low mortality) 
* Invader types 3 (specialists that are high reward producing), 4 (specialists that are high reward and pollen producing), and 8 (generalists that are high reward and pollen producing)
* Attachment algorithm 1 (random attachment), because the results observed for each attachment algorithm were qualitatively similar. 

```matlab
% To perform the simulation on a single network
networks = 1 

% To perform the simulation on a select range of networks.
networks = [1, 2, 3, 801, 802, 803] 

% To perform the simulation on all 1200 networks. If you choose to do this I recommended that you use a computing cluster!
networks = 1:1200 

run(networks)
```

### Outputs

***Time Series***

Graphical time series are produced for the first simulation in which a successful invasion occurs writted to the ```figures/timeseries/``` folder. These figures highlight the transient dynamics occuring during the 1200 timesteps directly after species introduction.
* ```plant_density_*.png```
  * Includes the density of the invasive species (in black) and all native plant species with which it shares a pollinator (in grey)
* ```nectar_density_*.png```
  * Includes the nectar density of the invasive species (in black) and all native plant species with which it shares a pollinator (in grey)
* ```foraging_preference_*.png```
  * Includes the nectar density of the invasive species (in black) and all native plant species with which it shares a pollinator (in grey)
* ```visit_quantity_*.png```
  * Includes the quantity of visits recieved by the invasive species (in black) and all native plant species with which it shares a pollinator (in grey)
* ```visit_quality_*.png```
  * Includes the quality of visits recieved by the invasive species (in black) and all native plant species with which it shares a pollinator (in grey)
* ```pol_density_*.png```
  * Includes the density of all pollinator species visiting the invasive plant (in black) and all other pollinator species (in grey)

***Numerical Data***

The numerical output from these simulations will be written to the ```data/``` folder. In the following files, the first half of columns are from time step 10000 just before species invasion after the original network has equilibrated, and the second half of columns are from time step 20000 at the end of the simulation. This data is used later in the analysis.
* Plant data: ```P_*.csv```
  * Each row is a unique plant species in the network, the first row is the invasive species
  * Columns are as follows: (extinct, plant density, reward density, total pollination events, quantity of visits, quality of visits, foraging effort) x2
* Pollinator data: ```A_*.csv```
  * Each row is a unique pollinator species in the network
  * Columns are as follows: (extinct, pollinator density, total visitation events) x2
* Pollinator foraging preference data: ```Alpha_*.csv```
  * Each row is a uniqe plant species in the network, the first row is the invasive species x2
  * Each column is a unique pollinator species in the network
  * Values are the proportional foraging effor a pollinator allocates to that plant

## Analysis 

To reproduce the analysis from our experiment, run ```run_analysis.R``` in R. In this script there is again a spot to specify which networks were included in the analysis.

``` R
# define the networks for which we are performing the analysis
networks <- c(1, 2, 3, 401, 402, 403, 801, 802, 803) #ENTER YOUR NETWORKS HERE

# build a table of all relevant network statistics characterizing the invasion
build_network_table_data(networks)

# compare rate of invasion success of each of the three invasive species types
compare_invasion_success()

# analyze the impact of species invasions on network structure and native plant visitation
compare_network_structure()

# compare the significance of the total initial connected pollinator density
compare_init_connected_pol_density()
```

### Outputs

```data/network_table_data.csv```
* A table of network statistics for each simulation before and after species invasion, as well as characteristics of the invasive species. 

```figures/barplot``` 
* Generates a barplot comparing the rate of invasion frequency for each of the three invader types.

```figures/boxplots``` 
* Generates boxplots as well as results from Wilcoxon Rank Sum Tests comparing native plant visitation and quantitative network structure before and after species invasions for each invader type:
 * ```indirect_visit_quality_i*.png```: compares quality of visits to plant species indirectly connected to the invasive species
 * ```indirect_visit_quantity_i*.png```: compares quantity of visits to plant species indirectly connected to the invasive species
 * ```wNODF_i*.png```: compares withe weighted nestedness of the network of foraging preferences
 * ```wMod_i*.png```: compares withe weighted modularity of the network of foraging preferences
* Generates boxplots as well as results from a Kruskal-Wallace Rank Sum Testcomparing initial total connected pollinator density for each invader across the following groups for each invader type:
 * ```init_connected_pol_vs_inv_K_i*.png```: compares the total initial connected pollinator density across invasive species' degree
 * ```init_connected_pol_vs_inv_success_i*.png```: compares the total initial connected pollinator density to invasion success

