library(RSiena)

# network CSV to use as dataset
network0 <- read.csv("network0.csv")

# convert row in network CSV to adjacency matrix
# adj_row: vector from slicing data frame
# player_names: used for indexing into network CSV
row_to_adj_mat <- function(adj_row, player_names) {
  n <- length(player_names)
  adj_mat <- matrix(0, nrow = n, ncol = n, 
                    dimnames = list(player_names, player_names))
  
  for (row_player in player_names) {
    for (col_player in player_names) {
      adj_row_var <- paste(row_player, "TO", col_player, sep = "_")  # column name in CSV file
      adj_mat[row_player, col_player] <- adj_row[1, adj_row_var]
    }
  }
  
  return(adj_mat)
}

# convert CSV to 3D array of adjacency matrices
player_names <- c("P1", "P2", "P3", "P4", "P5", "P6", "P7")
n <- length(player_names)
adj_mats <- array(NA, dim = c(n, n, nrow(network0)),
                  dimnames = list(player_names, player_names, NULL))
for (i in 1:nrow(network0)) {
  adj_mats[,,i] <- row_to_adj_mat(network0[i,], player_names)
}

# Create Siena data objects
network0_siena <- sienaDependent(adj_mats, allowOnly = F) 
data <- sienaDataCreate(network0_siena)
print01Report(data, modelname = "network0")

# Siena model
effects <- getEffects(data)
effectsDocumentation(effects)  # list effects

# transitive triplets problematic: only one player looks at another player, so 
# no timestep shows a transitive triplet (coeff -9.81, with very high 120 SE)
effects <- includeEffects(effects, recip, cycle3)
effects

algorithm <- sienaAlgorithmCreate(projname = "project_network0")
ans <- siena07(algorithm, data = data, effects = effects)
ans
