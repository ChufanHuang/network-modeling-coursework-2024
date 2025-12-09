# Practical 2 — ERGMs (Exponential Random Graph Models)


All explanations reflect **my own understanding**, not official course material.

---

## 1. Overview

This practical focuses on:

- Loading and inspecting the Knecht classroom friendship network  
- Computing basic network statistics (degree, density, etc.)  
- Fitting ERGMs:
  - **Edges-only model** (baseline independence)
  - **Dyadic dependence model** (edges + mutual)
  - **Markov model** (triangles)
  - **Curved ERGM** using `gwesp()` to avoid degeneracy
  - Adding **covariates** (gender homophily, primary school, delinquency)
- Diagnosing MCMC convergence
- Assessing goodness-of-fit (GOF)
- Simulating networks from the fitted model

---

##  2. Folder Structure

```
practical2_ergm/
├── practical2_ergm.R # Cleaned and annotated R script
└── data/
├── net.csv 
├── demographics.csv 
├── delinquency.csv 
└── primary.csv 
```

 In the official practical, delinquency is included inside `demographics.csv`.  
In this dataset version, it is provided separately, so it is merged explicitly in the script.

---

## 3. Dataset Description

This practical uses the Knecht classroom network, collected in the Netherlands (2003–2004).

- 25 students (11–13 years old)  
- Directed friendship nominations (“name up to 12 good friends”)  
- Multiple student attributes:
  - gender  
  - age  
  - ethnicity  
  - religion  
  - delinquency (stealing, vandalism, graffiti, fighting)
- Covariate indicating whether two students attended the same primary school

The network used here corresponds to Wave 3.

---

##  4. Steps in This Practical (My Implementation)

###  1. Load Data and Create Network Object
- Read `net.csv` as adjacency matrix  
- Load demographics and delinquency, then merge  
- Attach attributes to the `network` object  
- Add edge covariate: same primary school

###  2. Descriptive Statistics
Computed:

- Density  
- Outdegree / indegree distributions  
- Histograms  
- Basic visualization using `network` + `ggraph`

###  3. ERGM Models

#### **Model 0 — Edges Only (Bernoulli Graph)**
Baseline tie probability.

#### **Model 1 — Dyadic Dependence**
`edges + mutual`  
Used odds ratios to compare:
- probability of tie with no reciprocity  
- probability of reciprocating an existing tie

#### **Model 2 — Markov Dependence**
`edges + mutual + ttriple`  
Observed near-degeneracy.

#### **Model 2.2 — Curved ERGM**
`edges + mutual + gwesp(0.3, fixed = TRUE)`  
Stabilizes transitivity effects.

#### **Model 3 — Structural + Covariate Effects**
Included:
- mutuality  
- transitivity (`gwesp`)  
- gender homophily (`nodematch("gender")`)  
- same primary school (`edgecov(primary)`)  
- delinquency as sender/receiver effects (`nodeofactor`, `nodeifactor`)

###  4. MCMC Diagnostics
Used:

- Trace plots  
- Autocorrelation  
- Parameter mixing  

Ensured the chain stabilized.

###  5. Goodness of Fit
Compared simulated vs observed:

- Degree distribution  
- Geodesic distance  
- Edgewise shared partners  
- Triangles  

###  6. Simulation
Simulated new networks under both:

- Estimated parameters  
- Modified parameters (e.g., increased delinquency influence)

Plotted observed vs simulated networks (`patchwork`).


```r
simNets <- simulate(
  netw ~ edges + mutual + gwesp(decay=0.3,fixed=TRUE) +
    nodematch("gender") + edgecov(primary) +
    nodeofactor("delinquency") + nodeifactor("delinquency"),
  nsim = 1,
  coef = unlist(model3$coef)
)
```
Plotted:

- Observed network
- Simulated network
- Coloring by gender and delinquency levels

Then compared expected statistics:

```r
observed <- summary(netw ~ edges + mutual + gwesp(0.3, fixed=TRUE) +
                      nodematch("gender") + edgecov(primary) +
                      nodeofactor("delinquency") + nodeifactor("delinquency"))

simStats <- simulate(
  netw ~ edges + mutual + gwesp(0.3, fixed=TRUE) +
      nodematch("gender") + edgecov(primary) +
      nodeofactor("delinquency") + nodeifactor("delinquency"),
  nsim = 1000, output="stats"
)

expected <- apply(simStats, 2, mean)

```

## 7. Summary / Conclusion

**This practical demonstrated:**

- **ERGM is far more expressive than simple logistic regression or Erdős–Rényi models.**  
  It allows us to encode reciprocity, closure, homophily, attribute effects, and more.

- **Dyadic independence assumptions are unrealistic.**  
  The “edges-only” logistic regression model fails to capture real structures such as mutuality or clustering.

- **Triangle-based ERGMs easily become degenerate.**  
  The practical showed that including `ttriple` leads to instability.

- **Curved ERGMs using `gwesp()` solve degeneracy.**  
  `gwesp()` provides smooth control over transitivity and is much more stable.

- **Covariates matter.**  
  Gender homophily, primary school, and delinquency all contributed explanatory value.

- **Simulation is essential.**  
  ERGM coefficients must be interpreted through simulated networks rather than only through raw log-odds.

- **GOF and MCMC diagnostics are required for any valid ERGM.**  
  Even a converged model can be a poor fit.


