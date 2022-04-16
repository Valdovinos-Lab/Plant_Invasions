##############################################################################
# R script for simulation analysis.
# Author:
#   Sabine Dritz - sjdritz@ucdavis.edu
# Date:
#   4/16/2022
##############################################################################

source("analysis_functions.R")
library(stats)
library(bipartite)
library(graphics)
library(tidystats)

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
