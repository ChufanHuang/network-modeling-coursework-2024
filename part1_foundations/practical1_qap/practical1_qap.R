# ******************************************************************************
# Network Modeling – QAP and MR-QAP example
#
# This script runs (multiple) regression quadratic assignment procedures (QAP /
# MR-QAP) in R on the Lazega corporate law firm network (advice & friendship).
# The code is adapted for personal coursework and reproducibility.
# ******************************************************************************

# ----------------------------- Setup & packages ------------------------------ #

# (Optional) check working directory
getwd()

# In the GitHub repo this script is stored under practical1_qap/
# Data files are assumed to be in the subfolder "data" of this directory.
data_dir <- "data"

# Install packages manually if needed (not in the script):
# install.packages(c("sna", "network", "xtable"))

library(sna)
library(network)
library(xtable)

# ------------------------------ Load the data -------------------------------- #

# Adjacency matrices: advice and friendship networks
advice <- as.matrix(
  read.table(file.path(data_dir, "ELadv36.dat"), header = FALSE)
)
friendship <- as.matrix(
  read.table(file.path(data_dir, "ELfriend36.dat"), header = FALSE)
)

rownames(advice) <- 1:nrow(advice)
colnames(advice) <- 1:nrow(advice)
rownames(friendship) <- 1:nrow(advice)
colnames(friendship) <- 1:nrow(advice)

# Vertex attributes
attr <- read.table(
  file.path(data_dir, "ELattr36.dat"),
  header = TRUE
)
str(attr)

# -------------------------- QAP: advice ~ friendship ------------------------- #

# Do lawyers seek out their personal friends for work-related advice?

set.seed(1908)
permutations <- 1000

# Logistic QAP regression: advice as DV, friendship as IV
nl0 <- netlogit(
  advice,
  friendship,
  rep     = permutations,
  nullhyp = "qapy"   # permute labels of the dependent network
)

# Compare with alternative null hypothesis "qapspp"
nl0b <- netlogit(
  advice,
  friendship,
  rep     = permutations,
  nullhyp = "qapspp"
)
table(nl0$coefficients == nl0b$coefficients)

# Add coefficient names and inspect summary
nl0$names <- c("intercept", "friendship")
summary(nl0)

# Linear predictor and fitted values
lpred <- nl0$coefficients[1] +
  gvectorize(friendship, censor.as.na = FALSE) * nl0$coefficients[2]

fv <- exp(lpred) / (1 + exp(lpred))

# Check against values stored in the model object
table(lpred == nl0$linear.predictors)
table(fv    == nl0$fitted.values)

# Confusion matrix for a 0.5 threshold
table(
  Predicted = as.numeric(nl0$fitted.values >= 0.5),
  Actual    = gvectorize(advice, censor.as.na = FALSE)
)

# Odds ratio and percentage change in odds
or <- exp(coef(nl0))
or
paste(round((or - 1) * 100, 0), "%", sep = "")

# Predicted probability of an advice tie when friends vs. not friends
p_ftie   <- exp(nl0$coefficients[1] + nl0$coefficients[2] * 1) /
  (1 + exp(nl0$coefficients[1] + nl0$coefficients[2] * 1))
p_noftie <- exp(nl0$coefficients[1] + nl0$coefficients[2] * 0) /
  (1 + exp(nl0$coefficients[1] + nl0$coefficients[2] * 0))

p_ftie
p_noftie

# ---------------------------- MR-QAP regression ----------------------------- #
# Hypotheses:
# 1. Senior lawyers are less likely to ask for advice          (sender seniority)
# 2. Senior lawyers are more likely to be asked for advice     (receiver seniority)
# 3. Lawyers are more likely to ask office mates for advice    (same office)
# 4. Lawyers are more likely to ask same-school lawyers        (same school)
# 5. Advice and friendship relations are correlated            (friendship)

# Step 1: build dyadic covariate matrices

# Seniority (years with the firm)
seniority <- attr[, "seniority"]
senioritySender   <- matrix(seniority, 36, 36, byrow = FALSE)
seniorityReceiver <- matrix(seniority, 36, 36, byrow = TRUE)

# Same office
office     <- attr[, "office"]
sameOffice <- outer(office, office, "==") * 1

# Same school
school     <- attr[, "school"]
sameSchool <- outer(school, school, "==") * 1

# Friendship as dyadic predictor
friend <- friendship

# Combine covariates in a list (order matters)
zm <- list(
  senioritySender,
  seniorityReceiver,
  sameOffice,
  sameSchool,
  friend
)

# Step 2: run MR-QAP
set.seed(1908)
permutations <- 1000

nl <- netlogit(
  advice,
  zm,
  rep     = permutations,
  nullhyp = "qapspp"
)

nl$names <- c(
  "intercept",
  "senioritySender",
  "seniorityReceiver",
  "sameOffice",
  "sameSchool",
  "friendship"
)

summary(nl)

# Step 3: empirical p-values from the permutation distributions

z.values <- rbind(nl$dist, nl$tstat)

p.values <- function(x, permutations) {
  sum(abs(x[1:permutations]) > abs(x[permutations + 1])) / permutations
}

empirical.p.values <- apply(z.values, 2, p.values, permutations)
empirical.p.values

# Visualize permutation distributions
par(mfrow = c(2, 3))
for (i in 1:6) {
  hist(
    nl$dist[, i],
    breaks = 30,
    xlim   = c(
      min(c(nl$tstat[i], nl$dist[, i])) - 1,
      max(c(nl$tstat[i], nl$dist[, i])) + 1
    ),
    main = nl$names[i],
    xlab = "z-values"
  )
  abline(v = nl$tstat[i], lwd = 2, lty = 2)
}

# Step 4: format and export results
res    <- summary(nl)
expRes <- cbind(
  res$coefficients,
  exp(res$coefficients),
  res$se,
  res$pgreqabs
)

colnames(expRes) <- c("Est.", "exp(Est.)", "s.e.", "p-value")
rownames(expRes) <- res$names

expRes
write.csv(expRes, "resQAP.csv", row.names = TRUE)

# Export to LaTeX table
xtable(expRes, digits = 3)

# ------------------ Comparison with standard logistic regression ------------ #

# Build dyad-level data frame for glm()
dataLogit <- data.frame(
  sender   = c(row(advice)),
  receiver = c(col(advice)),
  adviceTie = c(advice)
)

dataLogit <- cbind(
  dataLogit,
  as.vector(senioritySender),
  as.vector(seniorityReceiver),
  as.vector(sameOffice),
  as.vector(sameSchool),
  as.vector(friend)
)

colnames(dataLogit) <- c(
  "sender",
  "receiver",
  "adviceTie",
  "senioritySender",
  "seniorityReceiver",
  "sameOffice",
  "sameSchool",
  "friend"
)

# Remove self-ties
dataLogit <- dataLogit[dataLogit$sender != dataLogit$receiver, ]

# Standard logistic regression (ignoring network dependence)
mod0 <- glm(
  adviceTie ~ senioritySender + seniorityReceiver +
    sameOffice + sameSchool + friend,
  family = "binomial",
  data   = dataLogit
)

summary(mod0)
summary(mod0)$coefficients[, "Pr(>|z|)"]
