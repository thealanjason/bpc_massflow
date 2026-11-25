library('coda')
library('reticulate')

az <- import("arviz")

# Read the MCMC output (NetCDF InferenceData written by the mcmc unit)
idata <- az$from_netcdf("mcmc_idata.nc")
post <- idata$posterior$to_array()$values  # dims: (parameter, chain, draw)

# Chained samples as (draw, chain, parameter)
chained_samples <- aperm(post, c(3, 2, 1))

# Flatten all chains into one (draw * chain, parameter) matrix
samples <- matrix(chained_samples, ncol = dim(chained_samples)[3])

# Convert to coda object
mcmc_chain <- mcmc(samples)

# Summary of the MCMC chain
summary(mcmc_chain)

plot(mcmc_chain)

dim(chained_samples)

chained_mcmc_chain <- mcmc(chained_samples)

# Reshape the array
num_chains <- dim(chained_samples)[2]
num_parameters <- dim(chained_samples)[3]

# Reshape the array into a list of chains
mcmc_chain_list <- vector(mode = "list", length = num_parameters)
for (param_index in 1:num_parameters) {
  mcmc_samples_param <- chained_samples[, , param_index]  # Extract samples for a parameter
  mcmc_chain_list[[param_index]] <- lapply(1:num_chains, function(i) as.mcmc(mcmc_samples_param[, i]))
}

gelman_rubin_results <- lapply(mcmc_chain_list, gelman.diag)