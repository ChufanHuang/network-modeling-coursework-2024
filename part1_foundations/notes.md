# Part I — Foundations of Network Modeling

*Notes based on my understanding of the first lectures (introduction, stylized models, CUG tests). Any mistakes are mine.*



## 1. What Is a Network Model?

A **network model** describes how a network is generated.  
Formally, it specifies a probability distribution over all possible networks:

\[
P(X \mid \theta), \quad X \in \mathcal{X}
\]

Where:

- \(X\): a network (often represented as an adjacency matrix)
- \(\theta\): model parameters (e.g., density, reciprocity, transitivity terms)
- \(\mathcal{X}\): set of all possible networks on a fixed node set

A good network model helps answer:

- Why does a given network look the way it does?
- Which micro-level mechanisms shape its structure?
- How do individual decisions create macro-level network patterns?



## 2. Stylized Network Models

Stylized models are simplified generative models used to illustrate how simple rules can produce complex network structures.  
They link **micro mechanisms** with **macro properties**.



### 2.1 Erdős–Rényi Random Graphs (ER)

**Model:**  
Each possible edge between \(N\) nodes appears **independently** with probability \(p\).

\[
P(X = x) = p^{m(x)} (1-p)^{M - m(x)}
\]

Where:

- \(m(x)\): number of realized edges in network \(x\)
- \(M = \frac{N(N-1)}{2}\) (undirected, no self-loops) or \(M = N(N-1)\) (directed)

**Assumptions:**

- All dyads are **independent**
- All dyads have the **same probability** \(p\)

**Consequences:**

- Randomly distributed ties
- Binomial / Poisson-like degree distribution
- Low clustering (very few triangles)
- No community structure
- Mainly useful as a **null model** or baseline



### 2.2 Configuration-Type Models

These models fix (or approximate) the **degree sequence**.

Examples:

- **Fixed-degree models**: networks are drawn uniformly from all graphs with a given degree sequence
- **Preferential attachment** (Barabási–Albert type):
  - New nodes attach with probability proportional to degree
  - Generates **heavy-tailed degree distributions** (“rich get richer”)

Intuition:  
Introduce **heterogeneity in popularity/activity** while still being relatively simple.



## 3. CUG Tests (Conditional Uniform Graph Tests)

CUG tests are used to assess whether an observed network statistic is **unusual** compared to a reference distribution under some null model.

**Idea:**

1. Specify a null model (e.g., ER with same density, or random graphs with same degree sequence).
2. Simulate many networks from this null.
3. Compute the statistic of interest (e.g., number of triangles, degree centralization) for each simulated network.
4. Compare the observed statistic to this null distribution.

If the observed statistic is in the extreme tail, it suggests that:

> “Under the chosen null model, this pattern would be very unlikely.”

So CUG tests tell us whether a pattern (like high clustering or strong centralization) is **more than we would expect by chance**, given some basic constraints (like density or degrees).



## 4. QAP: Motivation (Preview)

Standard regression assumes observations are **independent**.  
In network data, dyads (pairs of nodes) are typically **dependent**:

- If \(i\) is friends with \(j\), that may influence ties with \(k\)
- Triangles, reciprocity, and popularity all create dependencies

**Quadratic Assignment Procedures (QAP)** address this by:

- Estimating regression coefficients on dyadic data
- Using **permutations of node labels** to construct a valid null distribution
- Producing permutation-based \(p\)-values that respect network dependence

This is developed in detail in **Practical 1**.



## 5. My Take-aways from Part I

- Network models formalize intuitive mechanisms (e.g., “popular people get more ties”) as **probabilistic generative models**.
- Erdős–Rényi graphs are too simple for real social networks but very useful as a **baseline** for comparison.
- CUG tests help decide if features like clustering or centralization are unusually strong, given basic constraints.
- Many standard statistical tools break down because of **dyadic dependence**, which motivates QAP, ERGMs, and SAOMs later in the course.

These notes are intentionally concise so that the folder can serve as a **clean public record** of my coursework and as a reference for later network modeling projects.
