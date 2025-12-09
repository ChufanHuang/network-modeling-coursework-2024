# Practical 1 — QAP & MR-QAP (Multiple Regression Quadratic Assignment Procedure)

All explanations and notes below reflect **my own understanding**, not official course materials.

---

## 1. Overview

Quadratic Assignment Procedures (**QAP**) are widely used when analyzing network data because dyads are **not independent observations**.  
This practical focuses on:

- Visualizing networks  
- Running **bivariate QAP** (`advice ~ friendship`)  
- Running **MR-QAP** with multiple dyadic predictors  
- Interpreting regression coefficients using permutation-based p-values  
- Comparing results with a standard logistic regression (a misspecified i.i.d. model)

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
