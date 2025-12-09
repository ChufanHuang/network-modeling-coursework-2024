# Part III — Stochastic Actor-Oriented Models (SAOMs)
*Notes based on my understanding of the SAOM lecture (Nov 11, 2024).*

---

## 1. What Are SAOMs?

**Stochastic Actor-Oriented Models (SAOMs)** are models for **network evolution over time**.

Key ideas:

- The network changes in **small steps** (one tie at a time).
- **Actors** are the decision-makers; they control their **outgoing ties**.
- Time is modeled as **continuous**, but we only observe a **few discrete waves**.
- Estimation is typically done with **RSiena**.

---

## 2. Actor-Oriented Perspective

Intuition from the slides:

- “My friends have friends I don’t like.”
- “I’m in a dense clique.”
- “All my friends are popular.”
- “Am I happy with my current network?”

SAOM assumes:

- Each actor occasionally **gets an opportunity** to change one outgoing tie.
- The actor evaluates **how attractive** different possible networks are.
- The actor chooses the change that **improves** their objective function (stochastically).

---

## 3. Continuous-Time Network Change

We observe networks at times $t_1, t_2, \dots, t_M$:

$$
x(t_1),\ x(t_2),\ \dots,\ x(t_M).
$$

Between two observed waves $x(t_m)$ and $x(t_{m+1})$, the model assumes:

- Many **unobserved micro-steps**.
- Each micro-step toggles at most **one tie** (add or drop).
- Decisions are made by individual actors.

---

## 4. Social Mechanisms Captured by SAOM

Typical mechanisms:

- **Outdegree control**  
  Ties are costly $\Rightarrow$ actors limit the number of outgoing ties.

- **Reciprocity**  
  If $j$ names $i$, then $i$ is more likely to name $j$.

- **Transitivity / closure**  
  “Friends of my friends” tend to become friends.

- **Popularity / status**  
  Actors with many incoming ties attract even more ties.

- **Homophily**  
  Actors prefer others who are similar (gender, ethnicity, etc.).

These mechanisms appear through **effect statistics** $s_{ki}(x)$.

---

## 5. Objective Function

When actor $i$ considers changing a tie, the **objective function** is:

$$
f(i, x, \beta) = \sum_k \beta_k\, s_{ki}(x),
$$

where:

- $x$ is the current network,
- $s_{ki}(x)$ is the value of effect $k$ for actor $i$ in network $x$,
- $\beta_k$ is the parameter measuring the strength / direction of effect $k$.

Interpretation:

- If $\beta_k > 0$ and $s_{ki}(x)$ increases, the configuration becomes **more attractive**.
- If $\beta_k < 0$, the configuration is **penalized**.

## 6. Example Effect Statistics

Some examples from the lecture:

---

### 6.1 Structural Effects

- **Outdegree (density)**  
  $$ s_{\text{outdeg},i}(x) = \sum_j x_{ij} $$

- **Reciprocity**  
  $$ s_{\text{recip},i}(x) = \sum_j x_{ij} x_{ji} $$

- **Transitive triplets**  
  $$ s_{\text{transTrip},i}(x) = \sum_{j,h} x_{ij} x_{jh} x_{ih} $$

- **3-cycles**  
  $$ s_{\text{cycle3},i}(x) = \sum_{j,h} x_{ij} x_{jh} x_{hi} $$

---

### 6.2 Covariate-Based Effects

Let $v_j$ be a dummy variable (e.g., $v_j = 1$ if $j$ is female):

- **Ego effect (actor $i$’s own value)**  
  $$ s_{\text{ego},i}(x) = v_i \sum_j x_{ij} $$

- **Alter effect (preference for others with a certain value)**  
  $$ s_{\text{alter},i}(x) = \sum_j x_{ij} v_j $$

- **Homophily effect**  
  $$ s_{\text{homo},i}(x) = \sum_j x_{ij} \mathbf{1}(v_i = v_j) $$  
  where $\mathbf{1}(\cdot)$ is the indicator function.

---

## 7. Choice Probability for Tie Changes

Suppose actor $i$ has the opportunity to change one outgoing tie.  
They can toggle a tie to any $j$, or possibly do nothing.

For a candidate network $x^{(ij)}$ (after toggling $i \to j$), define its objective:

$$ f(i, x^{(ij)}, \beta) $$

The **multinomial choice probability** of choosing $j$ is:

$$
P(i \to j \mid x, \beta)
=
\frac{\exp\!\left( f(i, x^{(ij)}, \beta) \right)}
{\sum_{k} \exp\!\left( f(i, x^{(ik)}, \beta) \right)}
$$

Higher objective values $\Rightarrow$ higher probability of choosing that tie change.

---

## 8. Rate Function (How Often Actors Can Change Ties)

Actors do not change ties all the time.  
The **rate function** gives the expected number of opportunities per unit time.

A simple specification:

$$
\tau_i(x, \gamma)
=
\exp\!\left( \gamma_0 + \sum_k \gamma_k\, r_{ki}(x) \right)
$$

where $r_{ki}(x)$ are rate-related statistics and $\gamma$ are rate parameters.

The **intensity** of changing tie $i \to j$ is then:

$$
\lambda_{ij}(x;\, \beta, \gamma)
=
\tau_i(x, \gamma) \cdot P(i \to j \mid x, \beta)
$$

This defines a **continuous-time Markov process** on the space of networks.

---



## 9. Panel Data Setup

We observe the network at discrete times:

$$
x(t_1),\ x(t_2),\ \dots,\ x(t_M).
$$

Covariates can be:

- time-constant or time-varying,
- actor-level, dyadic, or exogenous.

SAOM treats each panel interval $[t_m, t_{m+1}]$ as the realization of many small micro-steps.

---

## 10. Model Assumptions (from the lecture)

Main assumptions:

1. The network follows a **continuous-time Markov process** between waves.  
2. The model is **conditional on the first wave** $x(t_1)$.  
3. At most **one tie changes at a time**.  
4. Each actor can change only their **outgoing** ties.  
5. Actors have **full knowledge** of the network when evaluating changes.

---

## 11. Estimation via Simulation (RSiena)

Parameter vector:

$$
\theta = (\gamma,\ \beta_1,\dots,\beta_K).
$$

Idea:

- For a candidate $\theta$, simulate network evolution between waves.
- Compute statistics on simulated networks.
- Adjust $\theta$ such that **expected statistics match observed statistics**.

This is done with a **Method of Moments (MoM)** approach plus **stochastic approximation**.

---

## 12. Method of Moments (MoM)

Let

$$
S = (S_\tau,\ S_1,\dots,S_K)
$$

be the vector of statistics, and let $s$ be the corresponding values computed from observed data.

We want:

$$
E_\theta[S] = s.
$$

This is solved iteratively using a Robbins–Monro type update.

---
## 13. Robbins–Monro Stochastic Approximation

Given parameter estimate \(\hat{\theta}_i\) at iteration \(i\), with simulated statistics \(S_i\),  
the Robbins–Monro update is:

\[
\hat{\theta}_{i+1}
=
\hat{\theta}_{i}
-
a_i\, D^{-1}\, ( S_i - s )
\]

where:

- \(a_i\): step size decreasing toward 0  
- \(D\): approximation of the Jacobian (derivative of expected statistics w.r.t. parameters)  
- \(S_i\): simulated statistics vector at iteration \(i\)  
- \(s\): observed statistics vector  

The algorithm converges once simulated and observed statistics become sufficiently close.

---

## 14. Convergence Criteria

For each effect \(k\), SAOM estimation uses a *t-ratio*:

\[
t_{\text{conv},k}
=
\frac{ S_k - s_k }{ \mathrm{sd}(S_k) }
\]

where:

- \(S_k\): mean of simulated statistics for effect \(k\)  
- \(s_k\): observed statistic  
- \(\mathrm{sd}(S_k)\): standard deviation of simulated statistics  

A typical convergence threshold:

\[
|t_{\text{conv},k}| \le 0.1 \quad \text{for all } k.
\]

Sometimes an overall discrepancy statistic is used:

\[
T = (S - s)^{\top} \Sigma^{-1} (S - s)
\]

where \(\Sigma\) is the covariance matrix of simulated statistics.

---

## 15. Multi-Period SAOM

With \(M\) observation waves, the parameter vector is:

\[
\theta = (\tau_1,\dots,\tau_{M-1},\ \beta_1,\dots,\beta_K)
\]

where:

- \(\tau_m\): rate parameters for period \([t_m, t_{m+1}]\)  
- \(\beta_k\): evaluation parameters for structural/covariate effects  

A rate statistic for period \(m\) is:

\[
S_{\tau_m}
=
\sum_{i,j}
\left|
X_{ij}(t_{m+1}) - X_{ij}(t_m)
\right|
\]

representing the number of tie changes in the interval.

Evaluation statistics aggregate across waves:

\[
S_k
=
\sum_{m=1}^{M}
s_k\!\left( X(t_m) \right)
\]

where \(s_k(\cdot)\) is the statistic for effect \(k\) on a single network.

---





## 16. Key Takeaways

This lecture clarified several important aspects of SAOMs:

- SAOMs model **continuous-time network evolution**, not static snapshots.
- Decisions about “who changes which tie at what moment” depend jointly on  
  rate functions and objective functions.
- Structural mechanisms (reciprocity, transitivity, popularity, closure) and  
  covariate mechanisms (homophily, behavioral similarity) are encoded through  
  network statistics \(s_{ki}(x)\).
- Comparison to ERGM:
  - ERGM models a *single* cross-section.
  - SAOM models *how the network changes* between waves.
- Parameter estimation relies on simulation, the method of moments, and  
  Robbins–Monro approximation.
- Convergence must be assessed through t-ratios and simulation diagnostics.

---

## 17. Reference

Snijders, T. A. B. (2017). *Stochastic Actor-Oriented Models for Network Dynamics*.  
See also the RSiena manual and course documentation.
