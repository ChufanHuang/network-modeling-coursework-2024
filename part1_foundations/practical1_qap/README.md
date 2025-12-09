# Practical 1 — QAP & MR-QAP (Multiple Regression Quadratic Assignment Procedure)


All explanations and notes below reflect **my own understanding**, not course materials.

---

## 1. Overview

Quadratic Assignment Procedures (**QAP**) are widely used when analyzing network data because dyads are **not independent observations**.  
This practical focuses on:

- Visualizing networks  
- Running **bivariate QAP** (`advice ~ friendship`)  
- Running **MR-QAP** with multiple dyadic predictors  
- Interpreting regression coefficients using permutation-based p-values  
- Comparing results with a standard logistic regression (misspecified model)

All computations are performed in R using the `sna` package.

---

## 2. Files in this folder

```plaintext
practical1_qap/
├── practical1_qap.R          # My cleaned and annotated R script
├── README.md                 # Notes, explanations, and instructions
└── data/                     
    ├── ELadv36.dat
    ├── ELfriend36.dat
    └── ELattr36.dat
```

## 3. Dataset description (Lazega Law Firm Network)

The dataset comes from:

> **Lazega, E. (2001). *The Collegial Phenomenon*. Oxford University Press.**

This widely used dataset contains:

- **36 partners** in a corporate law firm (Northeastern US)  
- **Advice network** (directed)  
- **Friendship network** (undirected)  
- Demographic attributes:
  - office location (Boston / Hartford / Providence)  
  - seniority (years in firm)  
  - law school (Harvard/Yale, UConn, other)

---

##  4. Key Concepts (my notes)

### **QAP (bivariate)**

Used to test relationships between two dyadic matrices.  
We estimate something like:

```math
`advice_ij = b0 + b1 * friendship_ij + error_ij`
```

Steps:

1. Compute the regression coefficient between the two networks.  
2. Permute the `dependent` network’s node labels.  
3. Recompute the coefficient for each permutation.  
4. Compare the observed coefficient to the permutation-based null distribution.  

Interpretation uses **empirical p-values** from the permutation distribution.

---

### **MR-QAP**

Extends QAP to multiple predictors, for example:

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

### Why not use standard logistic regression?

Because dyads violate the i.i.d. assumption.  
Standard GLM / logistic regression tends to **overestimate significance** and gives misleading p-values when applied directly to network ties.

---

##  5. Tasks & My Implementation

---

### **Task 1: QAP — advice ~ friendship**

Model:

`advice_ij = b0 + b1 * friendship_ij + error_ij`

**Result summary (my output):**

- `b1` (friendship) > 0 and statistically significant under 1000 permutations.  
- Interpretation: partners tend to seek advice from friends more than from non-friends.

I also computed:

- predicted probabilities  
- a confusion matrix based on a 0.5 threshold  
- odds ratios and percentage change in odds  
- a comparison between permutation schemes (`qapy` vs `qapspp`)  

---

### **Task 2: MR-QAP (multiple predictors)**

Predictor list:

| Variable           | Interpretation                                 |
|--------------------|-------------------------------------------------|
| `senioritySender`  | senior lawyers ask less advice                  |
| `seniorityReceiver`| senior lawyers are asked more                   |
| `sameOffice`       | office proximity                                |
| `sameSchool`       | educational similarity                          |
| `friendship`       | multiplexity (friendship → advice)              |

**Main findings (my results):**

- `senioritySender`: negative → senior lawyers ask less advice.  
- `seniorityReceiver`: positive → senior lawyers are asked more often.  
- `sameOffice`: positive → strong office homophily in advice ties.  
- `sameSchool`: weak or not significant (depending on permutations).  
- `friendship`: positive and significant → clear multiplexity between friendship and advice.

These results match known patterns in organizational networks.

---

### **Task 3: Empirical p-value visualization**

For each coefficient, I:

- plotted the permutation distribution of the test statistic, and  
- added the observed statistic as a vertical dashed line.  

This helps visually check whether the observed value is extreme under the null model.

---

### **Task 4: Standard logistic regression comparison**

Steps taken:

1. Converted the adjacency matrix into a dyad-level data frame (sender–receiver–tie).  
2. Added covariates (`senioritySender`, `seniorityReceiver`, `sameOffice`, `sameSchool`, `friend`).  
3. Removed diagonal dyads (`sender == receiver`).  
4. Estimated a standard logistic regression:

   ```r
   mod0 <- glm(
     adviceTie ~ senioritySender + seniorityReceiver +
       sameOffice + sameSchool + friend,
     family = "binomial",
     data   = dataLogit
   )
   summary(mod0)


---


This practical introduced the core logic of QAP and MR-QAP for modeling dyadic dependencies in networks.  
Through the Lazega law firm dataset, I implemented both bivariate and multivariate permutation-based models and compared them with a standard logistic regression to illustrate why traditional i.i.d. methods are inappropriate for network data.

