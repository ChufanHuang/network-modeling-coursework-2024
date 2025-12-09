# Part II — Exponential Random Graph Models (ERGMs)
*Notes based on my understanding of Lecture 4, Practical ERGM, and Lecture 6.*

---

## 1. What Are ERGMs?

An **Exponential Random Graph Model (ERGM)** specifies a probability distribution over all possible networks.

A generic form is:

$$
P(X = x; \theta) \propto \exp\left( \sum_k \theta_k \, z_k(x) \right)
$$

where:

- $z_k(x)$ are network statistics (e.g., edges, reciprocity, triangles, homophily)
- $\theta_k$ are parameters controlling how strongly each configuration is favored

Interpretation:

- $\theta_k > 0$ → networks with larger $z_k(x)$ are **more likely**
- $\theta_k < 0$ → networks with that configuration are **less likely**

---

## 2. Intuition: ERGM Building Blocks

ERGMs describe networks using **local graph patterns**:

- **Edges (density)**  
- **Reciprocity** (mutual ties)  
- **Popularity / activity** (in-stars, out-stars)  
- **Transitivity / closure** (triangles, shared partners)  
- **Homophily** on attributes (same office, same school, etc.)

These terms act like “Lego pieces”: by combining them, ERGMs can reproduce complex global structures observed in real networks.

---

## 3. ERGM as a Markov Random Field

ERGMs form a **Markov random field over edges**:

- Edges are *not* independent  
- The presence/absence of one tie can depend on other ties (e.g., triangles or reciprocity)

This is why standard dyadic logistic regression (which assumes independence) is not appropriate for network data.

---

## 4. ERGM and Markov Chain Interpretation

ERGMs can also be viewed as the **stationary distribution of a Markov chain** on the space of networks.

Toggling an edge $i \to j$ leads from network $x$ to $x^{i \to j}$.

The change in statistics is:

$$
\Delta z_k = z_k(x^{i \to j}) - z_k(x)
$$

A typical **Metropolis–Hastings acceptance probability** is:

$$
p_{\text{accept}} = \min\left( 1, \exp\left( \sum_k \theta_k \Delta z_k \right) \right)
$$

This is how networks are **simulated**: repeatedly propose edge toggles and accept them based on $\Delta z$.

---

## 5. ERGM Estimation: MCMCMLE

We want parameters $\theta$ such that:

$$
\mathbb{E}_\theta[z(X)] = z(x_{\text{obs}})
$$

Direct maximum likelihood is infeasible because the normalizing constant requires summing over all possible networks.

Therefore, ERGMs use:

### **MCMC Maximum Likelihood Estimation (MCMCMLE)**  
(Snijders' stochastic approximation — Robbins–Monro algorithm)

Process:

1. Start with an initial guess $\theta_0$
2. Simulate networks under $\theta$
3. Compare simulated vs. observed statistics  
4. Update $\theta$ to reduce the gap  
5. Repeat with decreasing step sizes until convergence

This is implemented in R’s `ergm` package (Hunter & Handcock, 2006).

---

## 6. MCMC Diagnostics

Because estimation uses MCMC, we must check:

- **Trace plots**  
  - Should fluctuate around a stable mean  
- **Histograms of simulated statistics**  
  - Should be centered near the observed statistic  
- **Autocorrelation**  
  - High autocorrelation = poor mixing

If mixing is poor:

- Increase burn-in  
- Thin the chain  
- Modify proposal distribution  
- Allow larger changes to the network  

Severe issues (e.g., chain jumps between empty and complete graphs) indicate **degeneracy**.

---

## 7. Goodness-of-Fit (GOF)

After fitting an ERGM, we check whether:

> Networks simulated from the model resemble the observed network.

GOF compares:

- Degree distribution  
- Shared partner / triangle counts  
- Geodesic distance distribution  
- Any structural summary not included in the model  

Even if the model converges, **poor GOF means the model is inadequate**.

---

## 8. Comparing Models: ER vs ERGM vs QAP

### **Erdős–Rényi (ER) model**
- Only an edges term  
- Equivalent to ERGM with one statistic: $z(x) = \text{edges}$  
- Produces unrealistic graphs  

### **ERGM**
- Includes multiple structural effects (mutual, triangles, homophily…)  
- Much more realistic generative model  

### **QAP regression**
- Tests **associations**, not generative mechanisms  
- Cannot model transitivity or clustering  

**Key difference:**  
ERGM = generative model; QAP = regression.

---

## 9. When to Use ERGMs

Use ERGMs when research questions involve:

- **Reciprocity**  
- **Transitivity / closure**  
- **Homophily**  
- **Popularity / activity** differences  
- Mechanisms that generate network structure  

ERGMs test **mechanisms**, not only correlations.

---

## 10. Interpretation of ERGM Coefficients

Each parameter $\theta_k$ affects the **log-odds** of an edge.

General interpretation:

$$
\Delta \log \text{odds}(i \to j) = \theta_k \cdot \Delta z_k
$$

Examples:

- `edges`: baseline tie probability  
- `mutual` > 0: mutual dyads preferred  
- `triangle` / `gwesp` > 0: transitivity  
- `nodematch("attr")` > 0: homophily  

Because of dependence, interpret effects using **simulation**, not only exponentiated coefficients.

---

## 11. Practical ERGM in R 

Typical ERGM workflow:

```r
model <- ergm(
  net ~ edges + mutual + gwesp(0.3, fixed = TRUE) +
    nodematch("office") + nodefactor("school")
)
```

