# *****************************************************************************************
# Network Modeling
# Practical 2: ERGMs on the Knecht friendship network
#
# This script:
#   - loads the Knecht classroom friendship data
#   - computes basic descriptives and visualizations
#   - fits several ERGMs (tie-independence, dyadic dependence, Markov-type, covariates)
#   - checks convergence and GOF
#   - simulates networks under modified parameters
#
# NOTE: This script reflects my own understanding and implementation.
# *****************************************************************************************

# ----------------------------------------------------------------------------------------
# 0. Working directory and packages
# ----------------------------------------------------------------------------------------

# Set the working directory to the folder that contains the "Knecht" subfolder.
# Example:
# setwd("~/Documents/network-modeling-coursework-2024/part2_ergm/practical2_ergm")

# setwd("...")  # <- uncomment and set path if you want to use setwd()
list.files()

# Packages used in this script
# install.packages(c("sna", "network", "ergm", "igraph", "RColorBrewer",
#                    "ggraph", "ggplot2", "patchwork"))

library(sna)
library(network)
library(ergm)
library(igraph)
library(RColorBrewer)
library(ggraph)
library(ggplot2)
library(patchwork)
library(grid)   # for arrow(), unit()

# ----------------------------------------------------------------------------------------
# 1. Loading data
# ----------------------------------------------------------------------------------------
# Data: Knecht classroom friendship network (Dutch secondary school)
# Source: http://www.stats.ox.ac.uk/~snijders/siena/siena.html

# Folder structure assumed:
#   Knecht/
#     ├── net.csv
#     ├── demographics.csv
#     └── primary.csv

# Friendship adjacency matrix (wave 3)
friendship <- as.matrix(read.csv("Knecht/net.csv", header = FALSE))
colnames(friendship) <- 1:nrow(friendship)
rownames(friendship) <- 1:nrow(friendship)

# Demographic characteristics of students
attributes <- read.csv("Knecht/demographics.csv", header = TRUE)
delinq <- read.csv("Knecht/delinquency.csv", header = TRUE)
attributes$delinquency <- delinq$delinquency

# Primary school indicator
primary <- as.matrix(read.csv("Knecht/primary.csv", header = FALSE))

# ----------------------------------------------------------------------------------------
# 2. Descriptive statistics and visualization
# ----------------------------------------------------------------------------------------

# Attributes
View(attributes)
table(attributes$gender)
table(attributes$age)
table(attributes$delinquency)

# Network
View(friendship)

nvertices <- nrow(friendship)               # number of vertices
nvertices

nedges <- sum(friendship)                  # number of ties
nedges

density <- nedges / (nvertices * (nvertices - 1))  # density
density

outdegree <- rowSums(friendship)           # outdegree distribution
mean(outdegree)
sd(outdegree)

indegree <- colSums(friendship)            # indegree distribution
mean(indegree)
sd(indegree)

par(mfrow = c(2, 1), mar = c(4, 3, 1, 3))
hist(outdegree, xlab = "Outdegree", col = "grey", main = "")
hist(indegree, xlab = "Indegree", col = "grey", main = "")

# Create a network object
netw <- network(friendship, directed = TRUE)

# Add vertex and edge attributes
netw %v% "gender"      <- attributes$gender
netw %v% "age"         <- attributes$age
netw %v% "ethnicity"   <- attributes$ethnicity
netw %v% "religion"    <- attributes$religion
netw %v% "delinquency" <- attributes$delinquency
netw %e% "primary"     <- primary

netw

# Basic network plot
plot(netw)

# Ggraph visualization with node/edge attributes
ggraph(netw) +
  geom_edge_link0(
    aes(colour = as.factor(primary)),
    arrow = arrow(
      angle  = 10,
      length = unit(4, "mm"),
      type   = "closed"
    )
  ) +
  scale_edge_colour_manual(
    name   = "Same primary",
    values = c("1" = "black", "0" = "darkgrey"),
    labels = c("0" = "false", "1" = "true")
  ) +
  geom_node_point(
    size  = 5,
    aes(
      shape = as.factor(gender),
      fill  = as.factor(religion)
    ),
    colour = "black"
  ) +
  scale_fill_discrete(
    name   = "Religion",
    labels = c(
      "0" = "missing",
      "1" = "Christian",
      "2" = "nonreligious",
      "3" = "other religion"
    )
  ) +
  guides(fill = guide_legend(
    override.aes = list(shape = 21),
    labels       = c(
      "0" = "missing",
      "1" = "Christian",
      "2" = "nonreligious",
      "3" = "other religion"
    )
  )) +
  scale_shape_manual(
    name   = "Gender",
    values = c("1" = 21, "2" = 22),
    labels = c("1" = "woman", "2" = "man")
  ) +
  theme_graph()

# ----------------------------------------------------------------------------------------
# 3. ERGM estimation
# ----------------------------------------------------------------------------------------

# ---------------------- 3.1 Tie-independence model -------------------------------------

# ERGM with only edges term (Erdős–Rényi type)
model0 <- ergm(netw ~ edges)
summary(model0)

# Logistic regression for comparison (i.i.d. dyads, misspecified)
diag(friendship) <- NA  # exclude diagonal (no self-ties)
model.log <- glm(c(friendship) ~ 1, family = binomial)  # intercept-only logit
summary(model.log)

# Probability of observing a tie under the ERGM:
theta1 <- model0$coef["edges"]
odds_edges <- exp(theta1)
p <- odds_edges / (1 + odds_edges)
p

# Compare with observed density
density

# ---------------------- 3.2 Dyadic dependence model ------------------------------------

set.seed(1986)
model1 <- ergm(netw ~ edges + mutual)
summary(model1)

# Probability of a non-reciprocating tie (no tie in opposite direction)
theta_edges  <- model1$coef["edges"]
theta_mutual <- model1$coef["mutual"]

# When there is no existing reciprocal tie, adding a tie changes only "edges"
odds_noRec <- exp(theta_edges)
p_noRec    <- odds_noRec / (1 + odds_noRec)

# Probability of reciprocating an existing tie
# Here, toggling the tie adds 1 edge AND 1 mutual
odds_Rec <- exp(theta_edges + theta_mutual)
p_Rec    <- odds_Rec / (1 + odds_Rec)

p_noRec
p_Rec

# ---------------------- 3.3 Markov random graph model ----------------------------------

model2 <- ergm(netw ~ edges + mutual + ttriple)
summary(model2)

# ---------------------- 3.4 Partial conditional dependence model -----------------------

# Solve near-degeneracy using a geometrically weighted edgewise shared partners term
set.seed(1986)
model2_2 <- ergm(netw ~ edges + mutual +
                   gwesp(decay = 0.3, fixed = TRUE))
summary(model2_2)

# Explore available terms
# vignette("ergm-term-crossRef")
# search.ergmTerms(categories = c("binary", "directed"))

# Add effects related to delinquency, gender homophily, and primary school
set.seed(1986)
model3 <- ergm(
  netw ~ edges +
    mutual +
    gwesp(decay = 0.3, fixed = TRUE) +
    nodematch("gender") +
    edgecov(primary) +
    nodeofactor("delinquency") +
    nodeifactor("delinquency")
)
summary(model3)

# ----------------------------------------------------------------------------------------
# 4. ERGM diagnostics and fit
# ----------------------------------------------------------------------------------------

# ---------------------- 4.1 MCMC convergence diagnostics --------------------------------
mcmc.diagnostics(model3)

# ---------------------- 4.2 Goodness of fit ---------------------------------------------
model3_gof <- gof(model3)
model3_gof

par(mfrow = c(2, 2), mar = c(5, 4, 4, 2))
plot(model3_gof)

# ----------------------------------------------------------------------------------------
# 5. Interpretation and simulation
# ----------------------------------------------------------------------------------------

# Parameter summary
summary(model3)

# Simulate networks with increased effects for delinquency node factors
newcoef <- model3$coef
# Assuming the last two coefficients are nodeofactor / nodeifactor for delinquency:
# (adjust indices if needed after checking names(model3$coef))
names(newcoef)
# Example: if they are the last two entries:
newcoef[length(newcoef) - 1] <- 0.7
newcoef[length(newcoef)]     <- 0.9

set.seed(1986)
simNets <- simulate(
  netw ~ edges + mutual + gwesp(decay = 0.3, fixed = TRUE) +
    nodematch("gender") + edgecov(primary) +
    nodeofactor("delinquency") + nodeifactor("delinquency"),
  nsim = 1,
  coef  = unlist(newcoef)
)

# Compare observed vs. simulated networks visually
p1 <- ggraph(netw) +
  geom_edge_link0() +
  geom_node_point(
    size  = 5,
    aes(
      shape  = as.factor(gender),
      colour = delinquency
    )
  ) +
  theme_graph() +
  ggtitle("Observed")

p2 <- ggraph(simNets) +
  geom_edge_link0() +
  geom_node_point(
    size  = 5,
    aes(
      shape  = as.factor(gender),
      colour = delinquency
    )
  ) +
  theme_graph() +
  ggtitle("Simulated (higher delinquency effects)")

p1 / p2 + plot_layout(guides = "collect")

# Compare expected statistics under new parameters with observed ones
observed <- summary(
  netw ~ edges + mutual + gwesp(decay = 0.3, fixed = TRUE) +
    nodematch("gender") + edgecov(primary) +
    nodeofactor("delinquency") + nodeifactor("delinquency")
)

set.seed(1986)
simNetsStat <- simulate(
  netw ~ edges + mutual + gwesp(decay = 0.3, fixed = TRUE) +
    nodematch("gender") + edgecov(primary) +
    nodeofactor("delinquency") + nodeifactor("delinquency"),
  nsim   = 1000,
  coef   = newcoef,
  output = "stats"
)

expected <- apply(simNetsStat, 2, mean)

observed
expected
