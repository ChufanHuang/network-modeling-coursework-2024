# network-modeling-coursework-2024
# Network Modeling – ETH Zürich (Fall 2024)

This repository collects my code, notes, and small projects for the **“Network Modeling”** course at ETH Zürich (Social Networks Lab), Fall 2024.  
The course introduces statistical models for social networks and their evolution, with a focus on **QAP regressions, ERGMs, and SAOMs**. :contentReference[oaicite:0]{index=0}  

---

## Course overview

- **University**: ETH Zürich, Social Networks Lab  
- **Course**: Network Modeling  
- **Semester**: Fall 2024  
- **Instructors**: Alvaro Uzaheta, Ivana Smokovic, Christoph Stadtfeld :contentReference[oaicite:1]{index=1}  

The course asks how and why social ties form, how local mechanisms (reciprocity, homophily, transitivity, etc.) generate global network structures, and how these structures in turn shape individual outcomes.  
It combines theory, lectures, and R-based practical sessions.

---

## Learning goals (condensed)

By the end of the course we should be able to: :contentReference[oaicite:2]{index=2}  

- Develop hypotheses about the **structure and dynamics** of (social) networks.  
- Apply **advanced statistical network methods** (QAP, ERGMs, SAOMs) in R.  
- Explain similarities and differences between these model families.  
- Interpret, critically assess, and report model results.  
- Use network models to address research questions from communication and other social sciences.

---

## Topics covered in this repo

This repo focuses on the **practical sessions** and **group assignments**:

1. **Practical 1 – QAP Regression** (07.10)  
   - Network permutations and QAP regression on dyadic data.  

2. **Practical 2 – ERGMs** (21.10)  
   - Specification, estimation, and basic goodness-of-fit for ERGMs.  

3. **Practical 3 – SAOMs** (18.11)  
   - SAOMs for the evolution of networks (RSiena-style workflow).  

4. **Group Assignment 1 – ERGMs**  
   - Applied ERGM modeling on an empirical network.  

5. **Group Assignment 2 – SAOMs**  
   - SAOMs for the co-evolution of networks and behaviors.  

The final practical lecture on 02.12 and the online exam on 18.12 are not included here. :contentReference[oaicite:3]{index=3}  

---

## Repository structure

Planned folder layout (will be filled as I upload my work):

```text
.
├── practical1_qap/           # QAP regression practical (R scripts / Rmd + notes)
├── practical2_ergm/          # ERGM practical
├── practical3_saom/          # SAOM practical
├── assignment1_ergm/         # Group Assignment 1
├── assignment2_saom/         # Group Assignment 2
└── data/                     # Anonymized / example data sets used in the exercises
