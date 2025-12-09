# Part III — Stochastic Actor-Oriented Models (SAOMs)
*Notes based on my understanding of the SAOM lecture (Nov 11, 2024).*

---

## 1. What Are SAOMs?

Stochastic Actor-Oriented Models (SAOMs) model **network evolution over continuous time**.

Key ideas:

- Networks change through **small micro-steps**.
- **Actors** control their *outgoing* ties.
- Actors occasionally get an **opportunity** to modify one tie.
- Objective: choose the tie change that improves their utility (probabilistically).
- We observe only discrete *waves*, but SAOM assumes many unobserved micro-changes between waves.

---

## 2. Actor-Oriented Perspective

Intuition:

- “My friends have friends I don’t like.”
- “I’m in a dense clique.”
- “All my friends are popular.”
- “Do I prefer this network configuration?”

Assumptions:

- Actors get *opportunities* at random times.
- In each step, they consider toggling one outgoing tie.
- They evaluate how attractive each possible change is.
- Probability of choosing a change depends on an **objective function**.

---

## 3. Continuous-Time Network Change

Observed networks:

$$
x(t_1),\ x(t_2),\ \dots,\ x(t_M)
$$

Between waves:

- Network evolves through many unobserved micro-steps.
- Each step toggles at most **one** tie.
- Actor $i$ decides only about ties $(i \to j)$.

---

## 4. Social Mechanisms Captured by SAOM

Typical structural mechanisms:

- **Outdegree control:** ties are costly  
- **Reciprocity:** if $j$ lists $i$, $i$ tends to list $j$  
- **Transitivity / closure:** friends-of-friends become friends  
- **Popularity:** actors with many incoming ties attract even more  
- **Homophily:** ties more likely between similar actors  

These mechanisms are represented through **effect statistics** $s_{ki}(x)$.

---

## 5. Objective Function

Actor $i$ evaluates a network configuration using:

$$
f(i, x, \beta) = \sum_k \beta_k\, s_{ki}(x)
$$

Where:

- $s_{ki}(x)$: statistic for effect $k$  
- $\beta_k$: weight (strength/direction)  

Interpretation:

- $\beta_k > 0$: configuration with higher $s_{ki}$ is more attractive  
- $\beta_k < 0$: configuration is penalized  

---

## 6. Example Effect Statistics

### 6.1 Structural Effects

- **Outdegree (density)**  
  $$
  s_{\text{outdeg},i}(x) = \sum_j x_{ij}
  $$

- **Reciprocity**  
  $$
  s_{\text{recip},i}(x) = \sum_j x_{ij} x_{ji}
  $$

- **Transitive triplets**  
  $$
  s_{\text{transTrip},i}(x) = \sum_{j,h} x_{ij} x_{jh} x_{ih}
  $$

- **3-cycles**  
  $$
  s_{\text{cycle3},i}(x) = \sum_{j,h} x_{ij} x_{jh} x_{hi}
  $$

---

### 6.2 Covariate-Based Effects

Let $v_j$ be a dummy variable (e.g. $v_j = 1$ if female):

- **Ego effect**  
  $$
  s_{\text{ego},i}(x) = v_i \sum_j x_{ij}
  $$

- **Alter effect**  
  $$
  s_{\text{alter},i}(x) = \sum_j x_{ij} v_j
  $$

- **Homophily effect**  
  $$
  s_{\text{homo},i}(x) = \sum_j x_{ij}\, \mathbf{1}(v_i = v_j)
  $$

---

## 7. Choice Probability for Tie Changes

When actor $i$ considers toggling a tie $i \to j$, the objective for the resulting network $x^{(ij)}$ is:

$$
f(i, x^{(ij)}, \beta)
$$

Probability of choosing $j$ follows a multinomial logit:

$$
P(i \to j \mid x, \beta)
=
\frac{\exp\!\left( f(i, x^{(ij)}, \beta) \right)}
{\sum_k \exp\!\left( f(i, x^{(ik)}, \beta) \right)}
$$

Higher objective value → higher probability that actor selects that tie change.

---

## 8. Rate Function (How Often Actors Can Change Ties)

Rate function for actor $i$:

$$
\tau_i(x, \gamma)
=
\exp\!\left( \gamma_0 + \sum_k \gamma_k r_{ki}(x) \right)
$$

Intensity of changing tie $i \to j$:

$$
\lambda_{ij}(x;\, \beta, \gamma)
=
\tau_i(x, \gamma) \cdot P(i \to j \mid x, \beta)
$$

Defines a **continuous-time Markov process** on networks.

---

## 9. Panel Data Setup

We observe:

$$
x(t_1),\ x(t_2),\dots,\ x(t_M)
$$

Between waves:

- many unobserved changes  
- SAOM simulates these micro-steps  

Covariates may be:

- actor-level  
- dyadic  
- time-varying or constant  

---

## 10. Model Assumptions

1. Network evolves as a **continuous-time Markov process**  
2. Conditioning on $x(t_1)$  
3. Only one tie changes at each micro-step  
4. Actors change only *outgoing* ties  
5. Actors evaluate changes based on the whole network  

---

## 11. Estimation via Simulation (RSiena)

Parameter vector:

$$
\theta = (\gamma,\, \beta_1, \dots, \beta_K)
$$

Process:

1. Propose parameters $\theta$  
2. Simulate network evolution between waves  
3. Compute simulated statistics  
4. Adjust parameters so **expected stats match observed stats**

Uses **Method of Moments** + **Robbins–Monro stochastic approximation**.

---

## 12. Method of Moments (MoM)

Let:

$$
S = (S_\tau,\ S_1,\dots,S_K)
$$

We want:

$$
E_\theta[S] = s
$$

RSiena solves this numerically through iterative approximation.

---

## 13. Robbins–Monro Stochastic Approximation

With parameter estimate $\hat{\theta}_i$ and simulated stats $S_i$:

$$
\hat{\theta}_{i+1}
=
\hat{\theta}_i
-
a_i\, D^{-1}\,(S_i - s)
$$

Where:

- $a_i$: decreasing step size  
- $D$: approximate Jacobian  
- $S_i$: simulated statistics  
- $s$: observed statistics  

---

## 14. Convergence Criteria

For effect $k$:

$$
t_{\text{conv},k}
=
\frac{ S_k - s_k }{\mathrm{sd}(S_k)}
$$

Rule of thumb:

$$
|t_{\text{conv},k}| \le 0.1
$$

Overall discrepancy:

$$
T = (S - s)^\top\, \Sigma^{-1}\, (S - s)
$$

---

## 15. Multi-Period SAOM

With $M$ waves:

$$
\theta = (\tau_1,\dots,\tau_{M-1},\ \beta_1,\dots,\beta_K)
$$

Rate statistic for period $m$:

$$
S_{\tau_m}
=
\sum_{i,j} \left| X_{ij}(t_{m+1}) - X_{ij}(t_m) \right|
$$

Evaluation statistics:

$$
S_k
=
\sum_{m=1}^M s_k(X(t_m))
$$

---

## 16. Key Takeaways

- SAOMs model **how networks change**, not static snapshots.  
- Actors modify only outgoing ties, based on objective functions.  
- Rate + evaluation functions jointly determine micro-steps.  
- Estimation relies on simulation, MoM, and stochastic approximation.  
- Diagnostics rely on t-ratios and goodness-of-fit comparisons.  
- SAOM complements ERGM:
  - ERGM: *Why does the network look like this?*  
  - SAOM: *How does the network change over time?*

---

## 17. Reference

Snijders, T. A. B. (2017). *Stochastic Actor-Oriented Models for Network Dynamics*.  
See also the RSiena manual and course documentation.

