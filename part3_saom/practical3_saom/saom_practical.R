# ------------------------------------------------------------------------------
# Network Modeling
# SAOMs for network (co-)evolution
#
# This script prepares data and fits Stochastic Actor-Oriented Models (SAOMs)
# using RSiena for:
#   1) Network evolution of friendship ties
#   2) Network–behavior co-evolution (friendship + delinquency)
#
# All comments reflect my own understanding of the practical.
# ------------------------------------------------------------------------------

# --------------------------------------------------------------------
# Working directory and packages
# --------------------------------------------------------------------
# TODO: set this to the folder where PracticalSAOM is unzipped
setwd("PATH/TO/PracticalSAOM")

# install.packages("RSiena")
# install.packages("sna")
# install.packages("parallel")

library(RSiena)
library(sna)
library(parallel)

# Optional helper functions (if available in the folder)
#   - printSiena.R: pretty printing of RSiena output
#   - siena07ToConverge.R: helper to iterate siena07 until convergence
source("printSiena.R")
source("siena07ToConverge.R")

# --------------------------------------------------------------------
# Loading data
# --------------------------------------------------------------------
# The folder Knecht_all contains longitudinal friendship data from a
# Dutch school class (Andrea Knecht et al., 4 waves).

# Friendship networks (4 waves)
net1 <- as.matrix(read.csv("Knecht_all/net1.csv", header = FALSE))
net2 <- as.matrix(read.csv("Knecht_all/net2.csv", header = FALSE))
net3 <- as.matrix(read.csv("Knecht_all/net3.csv", header = FALSE))
net4 <- as.matrix(read.csv("Knecht_all/net4.csv", header = FALSE))

# Demographics and delinquency
attributes <- read.csv("Knecht_all/demographics.csv", header = TRUE)
delinquent <- as.matrix(read.csv("Knecht_all/delinquency.csv", header = TRUE))[, -1]

# Same primary school (dyadic covariate)
primary <- as.matrix(read.csv("Knecht_all/primary.csv", header = FALSE))

# --------------------------------------------------------------------
# Network evolution: SAOM set-up
# --------------------------------------------------------------------

## Create Siena network object (dependent variable)
friendship <- sienaDependent(
  array(c(net1, net2, net3, net4), dim = c(25, 25, 4))
)
# 25 x 25 x 4: senders, receivers, 4 observation waves

## Covariates
gender      <- coCovar(attributes$gender)
age         <- coCovar(attributes$age)
ethnicity   <- coCovar(attributes$ethnicity)
religion    <- coCovar(attributes$religion)
delinquency <- varCovar(delinquent)        # changing behavior over time
primary     <- coDyadCovar(primary)        # dyadic covariate

## Combine into Siena data object
mydata <- sienaDataCreate(friendship, gender, delinquency, primary)
mydata

# --------------------------------------------------------------------
# Preconditions / basic description
# --------------------------------------------------------------------
# Stability across waves: Jaccard index
print01Report(mydata, modelname = "knechtInit")

# --------------------------------------------------------------------
# Model 1: basic network evolution model
# --------------------------------------------------------------------

## Effects specification
myeff <- getEffects(mydata)
myeff   # shows available default statistics

## Algorithm settings
myAlgorithm <- sienaAlgorithmCreate(
  projname = "friends_res",
  nsub     = 4,
  n3       = 3000,
  seed     = 1908
)

## Estimate basic model
model0 <- siena07(
  myAlgorithm,
  data       = mydata,
  effects    = myeff,
  returnDeps = TRUE,
  useCluster = TRUE,
  nbrNodes   = 4,
  batch      = FALSE
)

model0
printSiena(model0)

# Example (commented) of manual convergence diagnostics:
# t.conv <- apply(model0$sf, 2, mean) / apply(model0$sf, 2, sd)
# overall <- sqrt(t(apply(model0$sf, 2, mean)) %*%
#                 solve(cov(model0$sf)) %*%
#                 apply(model0$sf, 2, mean))

# Example of re-running from previous answer (if needed):
# model0 <- siena07(
#   myAlgorithm,
#   data       = mydata,
#   effects    = myeff,
#   returnDeps = TRUE,
#   prevAns    = model0,
#   useCluster = TRUE,
#   nbrNodes   = 4
# )

# Example of using helper to iterate until convergence:
# siena07ToConvergence(myAlgorithm, dat = mydata, eff = myeff)

# --------------------------------------------------------------------
# Model 2: richer network evolution model
# --------------------------------------------------------------------

# Inspect available effects for this data set
effectsDocumentation(myeff)

# Add structural effects
myeff <- includeEffects(myeff, transTrip, cycle3)

# Gender-related effects on friendship (ego, alter, same)
myeff <- includeEffects(
  myeff, egoX, altX, sameX,
  interaction1 = "gender"
)

# TODO: Hypothesis 5
# "Pupils tend to befriend pupils who have similar delinquent behaviour."
# Fill in the correct similarity effect for delinquency
myeff <- includeEffects(
  myeff, egoX, altX, ____,   # e.g. simX
  interaction1 = "____"      # e.g. "delinquency"
)

# Primary school dyadic effect
myeff <- includeEffects(
  myeff, X,
  interaction1 = "primary"
)

## Estimate extended network evolution model
modelEv <- siena07(
  myAlgorithm,
  data       = mydata,
  effects    = myeff,
  returnDeps = TRUE,
  useCluster = TRUE,
  nbrNodes   = 4
)

printSiena(modelEv)

# --------------------------------------------------------------------
# Goodness of fit for network evolution model
# --------------------------------------------------------------------

# Use parallel computation for GOF
cl <- makeCluster(4)

# Indegree distribution
gofEvId <- sienaGOF(
  modelEv,
  verbose = FALSE,
  varName = "friendship",
  IndegreeDistribution,
  cluster = cl
)

# Outdegree distribution
gofEvOd <- sienaGOF(
  modelEv,
  verbose = FALSE,
  varName = "friendship",
  OutdegreeDistribution,
  cluster = cl
)

# Triad census
gofEvTC <- sienaGOF(
  modelEv,
  verbose = FALSE,
  varName = "friendship",
  TriadCensus,
  cluster = cl
)

# Custom geodesic distance GOF
GeodesicDistribution <- function(
    i, data, sims, period, groupName,
    varName, levls = c(1:5, Inf), cumulative = TRUE) {

  x <- networkExtraction(i, data, sims, period, groupName, varName)
  a <- sna::geodist(symmetrize(x))$gdist

  if (cumulative) {
    gdi <- sapply(levls, function(l) sum(a <= l))
  } else {
    gdi <- sapply(levls, function(l) sum(a == l))
  }
  names(gdi) <- as.character(levls)
  gdi
}

gofEvGD <- sienaGOF(
  modelEv,
  verbose = FALSE,
  varName = "friendship",
  GeodesicDistribution
)

# Plot GOF diagnostics
plot(gofEvId)
plot(gofEvOd)
plot(gofEvGD)
plot(gofEvTC, center = TRUE, scale = TRUE)

# --------------------------------------------------------------------
# Network and behavior co-evolution
# --------------------------------------------------------------------

# Treat delinquency as a dependent behavior variable
delinquentbeh <- sienaDependent(delinquent, type = "behavior")

# New data object: friendship + delinquency + covariates
mydata <- sienaDataCreate(friendship, delinquentbeh, gender, primary)
mydata

# Preconditions: Jaccard + autocorrelation (Moran index)
print01Report(mydata, modelname = "knechtInitCoev")

moran1 <- nacf(net1, delinquent[, 1], lag.max = 1, type = "moran",
               neighborhood.type = "out", mode = "digraph")
moran2 <- nacf(net2, delinquent[, 2], lag.max = 1, type = "moran",
               neighborhood.type = "out", mode = "digraph")
moran3 <- nacf(net3, delinquent[, 3], lag.max = 1, type = "moran",
               neighborhood.type = "out", mode = "digraph")
moran4 <- nacf(net4, delinquent[, 4], lag.max = 1, type = "moran",
               neighborhood.type = "out", mode = "digraph")

autocorr <- rbind(moran1, moran2, moran3, moran4)
autocorr[, 2]

# See also:
# https://www.stats.ox.ac.uk/~snijders/siena/MoranDecompositionExample.R

# --------------------------------------------------------------------
# Co-evolution model: effects
# --------------------------------------------------------------------

myeff <- getEffects(mydata)

# Friendship evolution effects
myeff <- includeEffects(
  myeff, transTrip, cycle3,
  name = "friendship"
)

myeff <- includeEffects(
  myeff, egoX, altX, sameX,
  name = "friendship",
  interaction1 = "gender"
)

myeff <- includeEffects(
  myeff, X,
  name = "friendship",
  interaction1 = "primary"
)

# TODO: Hypothesis 5 (co-evolution version)
# "Pupils tend to befriend pupils who have similar delinquent behaviour."
myeff <- includeEffects(
  myeff, egoX, altX, ____,
  name = "friendship",
  interaction1 = "______"
)

# Behavior evolution (delinquency): structural + influence effects
myeff <- includeEffects(
  myeff, outdeg, indeg, avSim,
  name = "delinquentbeh",
  interaction1 = "friendship"
)

# TODO: Hypothesis 10
# "Boys tend to increase or maintain their level of delinquency more than girls."
myeff <- includeEffects(
  myeff, _______,
  name = "delinquentbeh",
  interaction1 = "_____"
)

myeff
effectsDocumentation(myeff)

# --------------------------------------------------------------------
# Co-evolution model estimation
# --------------------------------------------------------------------

myAlgorithm <- sienaAlgorithmCreate(
  projname = "CoevKnecht",
  nsub     = 4,
  n3       = 3000,
  seed     = 1908
)

modelCoev <- siena07(
  myAlgorithm,
  data       = mydata,
  effects    = myeff,
  returnDeps = TRUE,
  batch      = FALSE,
  useCluster = TRUE,
  nbrNodes   = 4
)

modelCoev

# --------------------------------------------------------------------
# Goodness of fit for co-evolution model
# --------------------------------------------------------------------

# Indegree distribution
gofCoevId <- sienaGOF(
  modelCoev,
  verbose = FALSE,
  varName = "friendship",
  IndegreeDistribution,
  cluster = cl
)

# Outdegree distribution
gofCoevOd <- sienaGOF(
  modelCoev,
  verbose = FALSE,
  varName = "friendship",
  OutdegreeDistribution,
  cluster = cl
)

# Triad census
gofCoevTC <- sienaGOF(
  modelCoev,
  verbose = FALSE,
  varName = "friendship",
  TriadCensus,
  cluster = cl
)

# Geodesic distance
gofCoevGD <- sienaGOF(
  modelCoev,
  verbose = FALSE,
  varName = "friendship",
  GeodesicDistribution
)

# Behavior distribution (delinquency)
gofCoevBeh <- sienaGOF(
  modelCoev,
  verbose = FALSE,
  varName = "delinquentbeh",
  BehaviorDistribution,
  cluster = cl
)

stopCluster(cl)

# Plot GOF diagnostics
plot(gofCoevId)
plot(gofCoevOd)
plot(gofCoevGD)
plot(gofCoevTC, center = TRUE, scale = TRUE)
plot(gofCoevBeh)

descriptives.sienaGOF(gofCoevGD)
descriptives.sienaGOF(gofCoevBeh)

# --------------------------------------------------------------------
# Final model output
# --------------------------------------------------------------------

printSienaCoev(modelCoev)
siena.table(modelCoev, type = "html", sig = TRUE)
