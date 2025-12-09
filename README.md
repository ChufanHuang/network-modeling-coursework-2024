# Network Modeling Coursework  

---

A comprehensive, graduate-level repository for statistical network modeling, including **QAP**, **ERGMs**, and **SAOMs**.

This repository documents my full workflow, notes, and executable code for a semester-long advanced course on **statistical network modeling**.  
It includes theory notes, practical exercises, and fully reproducible R scripts for:

- Stylized network models & CUG tests  
- QAP regression  
- Exponential Random Graph Models (ERGMs)  
- Stochastic Actor-oriented Models (SAOMs)  
- Network & behavior co-evolution modeling  

The goal of this project is to demonstrate mastery of modern computational techniques for modeling the **structure** and **evolution** of social networks.

---

##  Learning Objectives

This project demonstrates the ability to:

### **1. Develop hypotheses about network structures & dynamics**
Including mechanisms such as:

- reciprocity  
- transitivity / clustering  
- homophily  
- network–behavior co-evolution  

### **2. Apply advanced statistical network models**
Implemented in R using packages including `sna`, `igraph`, `ergm`, and `RSiena`:

- CUG tests  
- QAP regression (dyadic permutation models)  
- ERGMs (Markov random graph models)  
- SAOMs (actor-oriented, continuous-time models)  

### **3. Explain similarities & differences across models**
Covering conceptual distinctions such as:

- independence assumptions  
- Markov dependence  
- dynamic vs. cross-sectional models  
- generative vs. regression frameworks  

### **4. Perform full statistical workflows in R**
Including:

- parameter estimation  
- convergence diagnostics  
- goodness-of-fit evaluation  
- stochastic simulation of networks  
- interpretation via simulation rather than naïve coefficients  

### **5. Independently analyze substantive research questions**

All models are implemented end-to-end, including:

- data preprocessing  
- model specification  
- estimation  
- diagnostic checking  
- simulation-based interpretation  
- visualization  

---

##  Summary of Topics Covered

This project spans the full set of core methods in modern network science:

### **Part 1 — Foundations & QAP Regression**

- CUG tests  
- Stylized network models  
- Network permutations  
- QAP regression for dyadic data  
- Comparison with standard regression approaches  

### **Part 2 — Exponential Random Graph Models (ERGMs)**

- ERGM formulation  
- Change statistics & local dependencies  
- MCMCMLE estimation  
- Degeneracy & curved exponential families  
- Goodness-of-fit & convergence diagnostics  
- Simulation and effect interpretation  

### **Part 3 — Stochastic Actor-Oriented Models (SAOMs)**

- Continuous-time network evolution  
- Rate functions & evaluation functions  
- Objective functions  
- Network–behavior co-evolution modeling  
- Key effects: transitivity, similarity, influence, selection  
- Parallel estimation using RSiena  
- GOF across degree, triads, geodesics, and behavior distributions  

---

## Repository Structure

```text
network-modeling-coursework-2024
│
├── part1_foundations/
│   └── practical1_qap/
│       ├── data/
│       ├── practical1_qap.R
│       ├── README.md
│       └── notes.md
│
├── part2_ergm/
│   └── practical2_ergm/
│       ├── data/
│       ├── ergm_practical.R
│       ├── README.md
│       └── notes.md
│
├── part3_saom/
│   └── practical3_saom/
│       ├── saom_practical.R
│       ├── README.md
│       └── notes.md
│
├── LICENSE
└── README.md   
```
