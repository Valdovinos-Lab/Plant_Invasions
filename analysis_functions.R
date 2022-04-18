##############################################################################
# R functions for simulation analysis.
# Author:
#   Sabine Dritz - sjdritz@ucdavis.edu
# Date:
#   4/16/2022
##############################################################################

build_network_table_data <- function(networks) {
  
  ############################################################################
  # Goal: 
  #   To build a table of network statistics characterizing qualitative and 
  #   quantitative network structure before and after species invasion, as well 
  #   the characteristics of invasive species.
  
  # Data:
  #   All data: 
  #     - first half of columns are data from time step 10000 just before the invasion
  #     - second half of columns are data from time step 20000 just after the invasion
  #   Plant data: all files starting with "P_"
  #     - column ID: (extinct, plant density, reward density, total pollination events, quantity of visits, quality of visits, foraging effort)
  #     - row ID: unique plant species in the network (first row is invasive species)
  #   Animal data: all files starting with "A_"
  #     - columns ID: (extinct, pollinator density, total visitation events) 
  #     - row ID: unique pollinator species in the network
  #   Alpha data: all files starting with "Alpha_"
  #     - column ID: unique pollinator species in the network
  #     - row ID: unique plant species in the network (first row is invasive species)
  #     - values are the foraging effort allocated by a given pollinator to a given plant
  ############################################################################

  # Read in all the data
  plants  <- list.files(path = "./data", pattern = "P_")
  animals <- list.files(path = "./data", pattern = "A_")
  alphas  <- list.files(path = "./data", pattern = "Alpha_")
  
  # Read in network data
  network_data <- read.csv("./data/network_properties_1200m.csv", header = TRUE)
  network_data <- network_data[,1:23]
  
  # create table for all data
  table <- matrix(nrow = length(plants), ncol = 55)
  colnames(table) = c("matID","P","A","S", "C", "L/S", "L/A", "L/P", "A/P", "gA",
                      "gP", "GenSD", "VulSD", "mJP", "mJA", "maxJP", "maxJA", "NODFst",
                      "init_wNODF", "init_mod", "init_avg_indirect_quantity", "init_avg_indirect_quality",
                      "death_case", "inv_type", "InvP_k", "InvP_k_alg", "InvP_spec", 
                      "InvP_pol", "InvP_rew", "init_alpha", "init_A", "InvP_events", 
                      "InvP_rew_num", "InvP_num", "InvP_intro", "InvP_inv", "fin_alpha", 
                      "fin_A", "P1", "R1", "A1", "P2", "R2", "A2", "P_diff", "R_diff", 
                      "A_diff", "P_extinct", "A_extinct", "P_pol_diff", "A_visit_diff",
                      "fin_wNODF", "fin_mod", "fin_avg_indirect_quantity", "fin_avg_indirect_quality")
  
  # run on each network
  index = 1
  for (network_index in 1:length(networks)) {
    network = networks[network_index]
    
    # run for each mortality situation
    # 1) animals high mortality
    # 2) plants high mortality
    # 3) animals and plants low mortality
    # 4) animals and plants high mortality
    for (death_case in 3) {
      
      # run for each linking type
      # 1) links randomly
      # 2) links to specialists
      # 3) links to generalists
      for (link_case in 1) {
        
        # run for each type of invader
        # 1) specialists
        # 2) high pollen producing specialists
        # 3) high reward producing specialists
        # 4) high pollen and reward producing specialists
        # 5) generalists
        # 6) high pollen producing generalists
        # 7) high reward producing generalists
        # 8) high pollen and reward producing generalists
        inv_types <- c(3, 4, 8)
        for (inv_index in 1:3) {
          inv_type <- inv_types[inv_index]
          
          # Read in data for this network
          plant_data <- read.csv(paste("./data/", plants[index], sep = ""),   header = FALSE)
          animal_data <- read.csv(paste("./data/", animals[index], sep = ""), header = FALSE)
          alpha_data <- read.csv(paste("./data/", alphas[index], sep = ""),   header = FALSE)
          
          # Write column names
          colnames(plant_data) <- c("extinct", "plant_num", "reward_num", "tot_pol", "quantity", "quality", "alpha", "extinct_inv", "plant_num_inv", "reward_num_inv", "tot_pol_inv", "quantity_inv", "quality_inv", "alpha_inv")
          colnames(animal_data) <- c("extinct", "animal_num", "tot_visits", "extinct_inv", "animal_num_inv", "tot_visits_inv")
          
          # find indices of connected animals and plants
          init_alpha <- alpha_data[, 1:(ncol(alpha_data) / 2)]
          fin_alpha <- alpha_data[, (ncol(alpha_data) / 2 + 1):ncol(alpha_data)]
          pol_indices <- which(fin_alpha[1,] != 0)
          plant_indices <- c()
          for (i in 1:length(pol_indices)) {
            plant_indices <- c(plant_indices, which(init_alpha[, pol_indices[i]] != 0))
          }
          
          # characteristics of initial binary network
          table[index, "matID"]        <- network_data[network, 1]
          table[index, "P"]            <- network_data[network, 2]
          table[index, "A"]            <- network_data[network, 3]
          table[index, "S"]            <- network_data[network, 4]
          table[index, "C"]            <- network_data[network, 5]
          table[index, "L/S"]          <- network_data[network, 6]
          table[index, "L/A"]          <- network_data[network, 7]
          table[index, "L/P"]          <- network_data[network, 8]
          table[index, "A/P"]          <- network_data[network, 9]
          table[index, "gA"]           <- network_data[network, 10]
          table[index, "gP"]           <- network_data[network, 11]
          table[index, "GenSD"]        <- network_data[network, 12]
          table[index, "VulSD"]        <- network_data[network, 13]
          table[index, "mJP"]          <- network_data[network, 14]
          table[index, "mJA"]          <- network_data[network, 15]
          table[index, "maxJP"]        <- network_data[network, 16]
          table[index, "maxJA"]        <- network_data[network, 17]
          table[index, "NODFst"]       <- network_data[network, 18]
          
          # characteristics of quantitative network at equilibrium before invasion
          table[index, "init_wNODF"]   <- nest.smdm(init_alpha, weighted = TRUE)$WNODFmatrix
          table[index, "init_mod"]     <- computeModules(init_alpha)@likelihood
          table[index, "init_avg_indirect_quantity"] <- mean(plant_data[plant_indices, "quantity"])
          table[index, "init_avg_indirect_quality"] <- mean(plant_data[plant_indices, "quality"])
          
          #characteristics of invasive species
          table[index, "death_case"]   <- death_case
          table[index, "inv_type"]     <- inv_type
          table[index, "InvP_k"]       <- length(which(fin_alpha[1, ] != 0))
          table[index, "InvP_k_alg"]   <- link_case
          table[index, "InvP_spec"]    <- inv_type < 5
          table[index, "InvP_pol"]     <- (inv_type == 2) || (inv_type == 4) || (inv_type == 6) || (inv_type == 8)
          table[index, "InvP_rew"]     <- (inv_type == 3) || (inv_type == 4) || (inv_type == 7) || (inv_type == 8)
          table[index, "init_alpha"]   <- 0.0001 * table[index, "InvP_k"]
          table[index, "init_A"]       <- sum(animal_data[pol_indices, 2])
          
          #result of invasion attempt
          table[index, "InvP_events"]  <- plant_data[1, "tot_pol_inv"]
          table[index, "InvP_rew_num"] <- plant_data[1, "reward_num_inv"]
          table[index, "InvP_num"]     <- plant_data[1, "plant_num_inv"]
          table[index, "InvP_intro"]   <- !plant_data[1, "extinct_inv"]
          table[index, "InvP_inv"]     <- table[index, "InvP_num"] > (0.06)
          table[index, "fin_alpha"]    <- sum(fin_alpha[1, pol_indices])
          table[index, "fin_A"]        <- sum(animal_data[pol_indices, 5])
          
          #effects on native species
          table[index, "P1"]           <- sum(plant_data[-1, "plant_num"])
          table[index, "R1"]           <- sum(plant_data[-1, "reward_num"])
          table[index, "A1"]           <- sum(animal_data[-1, "animal_num"])
          table[index, "P2"]           <- sum(plant_data[-1, "plant_num_inv"])
          table[index, "R2"]           <- sum(plant_data[-1, "reward_num_inv"])
          table[index, "A2"]           <- sum(animal_data[-1, "animal_num_inv"])
          table[index, "P_diff"]       <- (table[index, "P2"] - table[index, "P1"]) / (table[index, "P2"] + table[index, "P1"])
          table[index, "R_diff"]       <- (table[index, "R2"] - table[index, "R1"]) / (table[index, "R2"] + table[index, "R1"])
          table[index, "A_diff"]       <- (table[index, "A2"] - table[index, "A1"]) / (table[index, "A2"] + table[index, "A1"])
          table[index, "P_extinct"]    <- sum(plant_data[-1, "extinct_inv"])
          table[index, "A_extinct"]    <- sum(animal_data[-1, "extinct_inv"])
          table[index, "P_pol_diff"]   <- (sum(plant_data[-1, "tot_pol_inv"]) - sum(plant_data[-1, "tot_pol"])) / (sum(plant_data[-1, "tot_pol_inv"]) + sum(plant_data[-1, "tot_pol"]))
          table[index, "A_visit_diff"] <- (sum(animal_data[-1, "tot_visits_inv"]) - sum(animal_data[-1, "tot_visits"])) / (sum(animal_data[-1, "tot_visits_inv"]) + sum(animal_data[-1, "tot_visits"]))
          table[index, "fin_wNODF"]   <- nest.smdm(fin_alpha, weighted = TRUE)$WNODFmatrix
          table[index, "fin_mod"]    <- computeModules(fin_alpha)@likelihood
          table[index, "fin_avg_indirect_quantity"] <- mean(plant_data[plant_indices, "quantity_inv"])
          table[index, "fin_avg_indirect_quality"] <- mean(plant_data[plant_indices, "quality_inv"])
          
          index = index + 1
          
        }
      }
    }
  }
  write.csv(table, "network_table_data.csv")
}

compare_invasion_success <- function() {

  ##############################################################################
  # Goal:
  #   To compare rate of invasion success of each of the three invasive species
  #   types.
  
  # Data:
  #   network_data: table of all network statistics characterizing species invasions
  ##############################################################################
  
  # read in network data
  network_data <- read.csv("network_table_data.csv", header = TRUE)
  network_data_m3 <- network_data[network_data$death_case == 3,]
  network_data_m3_l1 <- network_data_m3[network_data_m3$InvP_k_alg == 1,] 
  inv_types <- c(3, 4, 8)
  
  success_rate <- c(0,0,0)
  for (inv_type in 1:length(inv_types)) {
    inv_data <- network_data_m3_l1[network_data_m3_l1$inv_type == inv_types[inv_type],]
    success_rate[inv_type] <-  sum(inv_data$InvP_inv == 1) / nrow(inv_data) 
  }
  png("./figures/invasion_success_rate.png")
  barplot(success_rate)
  dev.off()
}

compare_network_structure <- function() {
  
  ##############################################################################
  # Goal:
  #   To analyze the effect of species invasions on native plans and pollinators
  #   and on the quantitative network structure of foraging efforts.
  
  # Data:
  #   network_data: table of all network statistics characterizing species invasions,
  #   - data was divided to only consider simulations where a species successfully 
  #     invaded the network
  
  # Statistical test:
  #   Wilcoxon Rank Sum Test
  #     -comparing network statistics at time step 10000 immediately before species invasion
  #       and at time step 20000
  #     -to analyze the effect on native plants and pollinators, tests were 
  #       performed separately for different invader types (3, 4, 8)
  #     -to analyze the effect on quantitative network structure, tests were
  #       performed separately for different invader types (3, 4, 8) and different
  #       network groups (S=40, C=0.25), (S=90, C=0.15), (S=200, C=0.06)
  ##############################################################################
  
  # read in network data
  network_data <- read.csv("network_table_data.csv", header = TRUE)
  network_data_m3 <- network_data[network_data$death_case == 3,]
  network_data_m3_l1 <- network_data_m3[network_data_m3$InvP_k_alg == 1,]
  network_data_m3_l1_inv <- network_data_m3_l1[network_data_m3_l1$InvP_inv == 1,]
  inv_types <- c(3, 4, 8)
  net_groups <- c(400, 800, 1200)
  
  print("Results of the Wilcoxon Rank Sum Test for the following statistics before and after species invasions:")
  cat("\n")
  
  for (inv_type in 1:length(inv_types)) {
    
    # subset data for only one invader type
    inv_data <- network_data_m3_l1_inv[network_data_m3_l1_inv$inv_type == inv_types[inv_type],]
    
    if(nrow(inv_data) > 1) {
      print(paste("Invader: ", inv_types[inv_type]))
      result <- tidy_stats(wilcox.test(inv_data$init_A, inv_data$fin_A))
      print(paste("Total connected pollinator density, p_value: ", result$statistics$p))
      png(paste("./figures/boxplots/connected_pol_density_i", inv_types[inv_type], ".png", sep = ""))
      boxplot(c(inv_data$init_A, inv_data$fin_A) ~ c(rep(1, length(inv_data$init_A)), rep(2, length(inv_data$fin_A))))
      dev.off()
      
      result <- tidy_stats(wilcox.test(inv_data$init_avg_indirect_quantity, inv_data$fin_avg_indirect_quantity))
      print(paste("Visit quantity to indirectly connected native plants, p_value: ", result$statistics$p))
      png(paste("./figures/boxplots/indirect_visit_quality_i", inv_types[inv_type], ".png", sep = ""))
      boxplot(c(inv_data$init_avg_indirect_quantity, inv_data$fin_avg_indirect_quantity) ~ c(rep(1, length(inv_data$init_avg_indirect_quantity)), rep(2, length(inv_data$fin_avg_indirect_quantity))))
      dev.off()
      
      result <- tidy_stats(wilcox.test(inv_data$init_avg_indirect_quality, inv_data$fin_avg_indirect_quality))
      print(paste("Visit quality to indirectly connected native plants, p_value: ", result$statistics$p))
      png(paste("./figures/boxplots/indirect_visit_quantity_i", inv_types[inv_type], ".png", sep = ""))
      boxplot(c(inv_data$init_avg_indirect_quality, inv_data$fin_avg_indirect_quality) ~ c(rep(1, length(inv_data$init_avg_indirect_quality)), rep(2, length(inv_data$fin_avg_indirect_quality))))
      dev.off()
      cat("\n")
    }
    
    for (net_group in 1:length(net_groups)) {
      
      # subset data for only one group of network sizes
      net_data <- inv_data[inv_data$matID < net_groups[net_group],]
      if (net_group > 1) {
        net_data <- net_data[net_data$matID > net_groups[net_group - 1],]
      }
      
      if (nrow(net_data) > 1) {
        print(paste("Invader: ", inv_types[inv_type], ", Nework group: ", net_groups[net_group]))
        
        result <- tidy_stats(wilcox.test(net_data$init_wNODF, net_data$fin_wNODF))
        print(paste("Weighted nestedness, p_value: ", result$statistics$p))
        png(paste("./figures/boxplots/wNODF_i", inv_types[inv_type], "_group_", net_group, ".png", sep = ""))
        boxplot(c(net_data$init_wNODF, net_data$fin_wNODF) ~ c(rep(1, length(net_data$init_wNODF)), rep(2, length(net_data$fin_wNODF))))
        dev.off()
        
        result <- tidy_stats(wilcox.test(net_data$init_mod, net_data$fin_mod))
        print(paste("Weighted modularity, p_value: ", result$statistics$p))
        png(paste("./figures/boxplots/wMod_i", inv_types[inv_type], "_group_", net_group, ".png", sep = ""))
        boxplot(c(net_data$init_mod, net_data$fin_mod) ~ c(rep(1, length(net_data$init_mod)), rep(2, length(net_data$fin_mod))))
        dev.off()
        cat("\n")
      }
    }
  }
}

compare_init_connected_pol_density <- function() {
  
  ##############################################################################
  # Goal: 
  #   To analyze the relationship between invasive species degree and the total
  #   initial connected pollinator density as well as the relationship between
  #   total initial connected pollinator density and invasion success
  
  # Data:
  #   network_data: 
  #     - table of all network statistics characterizing species invasions
  
  # Statistical test:
  #   Kruskal-Wallis Rank Sum Test
  #   -determining whether the initial total connected pollinator abundance 
  #    varies across the invasive specie's degree
  #   -determining whether the initial total connected pollinator abundance 
  #    varies between successful and unsuccessful invasions
  ##############################################################################
  
  # read in network data
  network_data <- read.csv("network_table_data.csv", header = TRUE)
  
  print("Results of the Kruskal Wallace Rank Sum Test for significant variation in initial total connected pollinator density across the following groups: ")
  cat("\n")
  
  #performing kruskal's test
  result <- tidy_stats(kruskal.test(init_A ~ InvP_k, data = network_data))
  print(paste("Invasive species degree, p-value: ", result$statistics$p))
  
  result <- tidy_stats(kruskal.test(init_A ~ InvP_inv, data = network_data))
  print(paste("Invasion success, p-value: ", result$statistics$p))
}


