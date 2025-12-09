# Practical 1 — QAP & MR-QAP  
(*Multiple Regression Quadratic Assignment Procedure*)

All explanations and notes below reflect **my own understanding**, not course materials.

---

## 1. Overview

Quadratic Assignment Procedures (**QAP**) are widely used when analyzing network data because dyads are **not independent observations**.

This practical focuses on:

- Visualizing networks  
- Running **bivariate QAP** (`advice ~ friendship`)  
- Running **MR-QAP** with multiple dyadic predictors  
- Interpreting coefficients via permutation-based p-values  
- Comparing results with a misspecified standard logistic regression  

All computations were done in **R** using the `sna` package.

---

## 2. Files in this folder

```
practical1_qap/
├── practical1_qap.R          # My cleaned and annotated R script
├── README.md                 # Notes, explanations, and instructions
└── data/                     
    ├── ELadv36.dat
    ├── ELfriend36.dat
    └── ELattr36.dat
```

---

## 3. Dataset description (Lazega Law Firm Network)

The dataset comes from:

> **Lazega, E. (2001). *The Collegial Phenomenon*. Oxford University Press.**

Included networks and attributes:

- **36 partners** in a corporate law firm  
- **Advice network** (directed)  
- **Friendship network** (undirected)  
- **Attributes**: office, seniority, law school  

---

## 4. Key Concepts (my notes)

### QAP (bivariate)

Used to assess the relationship between two dyadic matrices.

The model we conceptually examine is:

$$
\text{advice}_{ij}
=
\beta_0
+
\beta_1\, \text{friendship}_{ij}
+
\varepsilon_{ij}
$$

QAP procedure:

1. Compute the observed regression coefficient.  
2. **Permute node labels** in the *dependent network*.  
3. Re-estimate the coefficient for each permutation.  
4. Compare the observed statistic to the permutation distribution.  

The p-value is the **fraction of permutations** that yield a coefficient as extreme as the observed one.

---

### MR-QAP

Extends QAP to multiple predictors:

- sender seniority  
- receiver seniority  
- same office  
- same school  
- friendship  

MR-QAP solves:

- dyadic dependence  
- dyadic autocorrelation  
- multicollinearity  
- valid p-values via permutation  

---

### Why not use standard logistic regression?

Because dyads are **not independent**.

A standard GLM (logit/probit):

- incorrectly assumes i.i.d. errors  
- strongly **inflates significance**  
- produces misleading inference for network data  

---

## 5. Tasks & My Implementation

---

### Task 1 — Bivariate QAP: `advice ~ friendship`

Conceptual model:

$$
\text{advice}_{ij}
=
\beta_0
+
\beta_1\, \text{friendship}_{ij}
+
\varepsilon_{ij}
$$

**My results:**

- \( \beta_1 > 0 \), significant under 1000 permutations  
- Interpretation: partners preferentially seek advice from their friends  

Additional computations included:

- predicted probabilities  
- confusion matrix (threshold = 0.5)  
- odds ratios  
- comparison of permutation schemes (`qapy` vs. `qapspp`)  

---

### Task 2 — MR-QAP with multiple predictors

| Variable             | Interpretation                                  |
|---------------------|--------------------------------------------------|
| `senioritySender`   | more senior lawyers give less advice             |
| `seniorityReceiver` | more senior lawyers are asked more               |
| `sameOffice`        | strong office homophily                          |
| `sameSchool`        | weak / inconsistent effect                       |
| `friendship`        | clear positive multiplexity                      |

**My findings:**

- `senioritySender`: negative  
- `seniorityReceiver`: positive  
- `sameOffice`: strong positive  
- `sameSchool`: small / not significant  
- `friendship`: strong positive and significant  

These align with prior findings from organizational network literature.

---

### Task 3 — Permutation-based empirical p-value visualization

For each coefficient:

- computed empirical distribution from permutations  
- overlaid observed statistic  
- visually checked extremity relative to null distribution  

This is essential because **QAP tests against a network-structured null**, not a classical regression null.

---

### Task 4 — Standard logistic regression comparison

Steps:

1. Convert adjacency matrix into dyad-level dataframe.  
2. Attach covariates for sender and receiver.  
3. Exclude diagonal pairs.  
4. Estimate logistic regression:

```r
mod0 <- glm(
  adviceTie ~ senioritySender + seniorityReceiver +
    sameOffice + sameSchool + friend,
  family = "binomial",
  data   = dataLogit
)
summary(mod0)
```

Findings:

- GLM produces *much smaller p-values* than MR-QAP  
- Demonstrates **model misspecification** when independence is assumed  

---

## Summary

This practical demonstrated:

- How QAP and MR-QAP properly account for dyadic dependence  
- Why permutation-based inference is necessary for network regression  
- How multiplexity (friendship → advice) structures organizational networks  
- How inappropriate the standard GLM is for network data  

MR-QAP provides valid inference in the presence of network autocorrelation, while GLMs do not.

