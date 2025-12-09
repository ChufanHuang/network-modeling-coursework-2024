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

### 4.1 QAP (bivariate)

Used to test relationships between two dyadic matrices.  
We estimate something like:


```math
\text{advice}_{ij}
=
\beta_0 + \beta_1 \,\text{friendship}_{ij} + \varepsilon_{ij}
```

Steps:

1. Compute the regression coefficient between the two networks.  
2. Permute the **node labels** of the dependent network (rows/columns simultaneously).  
3. Recompute the coefficient for each permutation.  
4. Compare the observed coefficient to the permutation-based null distribution.

Interpretation uses **empirical p-values** from the permutation distribution.

---

### 4.2 MR-QAP

Extends QAP to multiple predictors, e.g.:

- sender seniority  
- receiver seniority  
- same office  
- same school  
- friendship ties  

MR-QAP handles:

- non-independence of dyads  
- multicollinearity among covariates  
- permutation-based significance testing  

---

### 4.3 Why not use standard logistic regression?

Because dyads violate the i.i.d. assumption.  
Standard GLM / logistic regression tends to **overestimate significance** and gives misleading p-values when applied directly to network ties.

---

## 5. Tasks & My Implementation

---

### **Task 1: QAP — advice ~ friendship**

Model:

```math
\text{advice}_{ij}
=
\beta_0 + \beta_1 \,\text{friendship}_{ij} + \varepsilon_{ij}
```
**Result summary (my output):**

- $\beta_1$ (friendship) was **positive** and significant under 1000 permutations.  
- Interpretation: partners tend to seek advice from friends more than non-friends.

I also computed:

- predicted probabilities  
- confusion matrix at 0.5 threshold  
- odds ratios  
- comparison of permutation schemes (`qapy` vs. `qapspp`)

---

### **Task 2: MR-QAP (multiple predictors)**

Predictor list:

| Variable             | Interpretation                                  |
|----------------------|--------------------------------------------------|
| `senioritySender`    | senior lawyers ask less advice                   |
| `seniorityReceiver`  | senior lawyers are asked more                    |
| `sameOffice`         | office proximity                                 |
| `sameSchool`         | educational similarity                           |
| `friendship`         | multiplexity (friendship → advice)               |

**Main findings:**

- `senioritySender`: negative → senior lawyers ask less advice  
- `seniorityReceiver`: positive → senior lawyers are asked more  
- `sameOffice`: positive → strong office homophily  
- `sameSchool`: weak or null  
- `friendship`: strong, positive, significant  

These match well-known organizational patterns.

---

### **Task 3: Empirical p-value visualization**

For each coefficient I plotted:

- permutation distribution  
- observed statistic (vertical dashed line)

This makes the significance visually interpretable.

---

### **Task 4: Standard logistic regression comparison**

```r
mod0 <- glm(
  adviceTie ~ senioritySender + seniorityReceiver +
    sameOffice + sameSchool + friend,
  family = "binomial",
  data   = dataLogit
)
summary(mod0)
```

Comparing this model with MR-QAP highlights that ignoring dyadic dependence **inflates significance**.

---

This practical introduced the core logic of QAP and MR-QAP for modeling dyadic dependencies in networks, using the Lazega law firm dataset to illustrate permutation-based inference vs. naïve i.i.d. regression.


## Summary

This practical demonstrated:

- How QAP and MR-QAP properly account for dyadic dependence  
- Why permutation-based inference is necessary for network regression  
- How multiplexity (friendship → advice) structures organizational networks  
- How inappropriate the standard GLM is for network data  

MR-QAP provides valid inference in the presence of network autocorrelation, while GLMs do not.

