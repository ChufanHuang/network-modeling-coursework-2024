# SAOM Practical — Stochastic Actor-Oriented Models (RSiena)


---

# 1. What Are SAOMs?

SAOMs model **continuous-time stochastic processes** governing:

- Network evolution (changes in ties)
- Behavioral evolution (changes in node attributes)
- Network–behavior co-evolution (peer influence and selection)

The core idea:

> Actors change outgoing ties or behavior in many tiny steps between waves, optimizing their own objective function.

## 1.1 Objective Function

For actor *i*, the probability of choosing a change from state *x* to *x′* is:

$$
P(x \rightarrow x') \propto \exp(f_i(x'))
$$

where the objective function is:

$$
f_i(x) = \sum_k \beta_k \, s_{ki}(x)
$$

- $s_{ki}(x)$ = statistics relevant to actor *i* (e.g., degree, transitivity, similarity)
- $\beta_k$ = parameters to estimate

Actors prefer micro-steps that increase $f_i(x)$.

---

# 2. Data Used in This Practical

Longitudinal classroom friendship data (Knecht dataset):

- 25 students
- 4 observed friendship networks (waves 1–4)
- Node attributes:
  - gender, age, ethnicity, religion
- Behavior variable:
  - delinquency (4 waves)
- Dyadic covariate:
  - same primary school (0/1)

Files:

```
net1.csv
net2.csv
net3.csv
net4.csv
demographics.csv
delinquency.csv
primary.csv
```

---

# 3. SAOM Data Setup

## 3.1 Dependent network

```r
friendship <- sienaDependent(
  array(c(net1, net2, net3, net4), dim = c(25, 25, 4))
)
```

## 3.2 Covariates

- Constant covariates → `coCovar()`
- Time-varying behavior → `varCovar()`
- Dyadic covariate → `coDyadCovar()`

```r
gender      <- coCovar(attributes$gender)
delinquency <- varCovar(delinquent)
primary     <- coDyadCovar(primary)
```

## 3.3 Combine into Siena data object

```r
mydata <- sienaDataCreate(friendship, gender, delinquency, primary)
```

---

# 4. Preconditions and Descriptive Checks

## 4.1 Network stability (Jaccard index)

```r
print01Report(mydata, modelname="knechtInit")
```

Higher Jaccard → more stable between waves.

## 4.2 (Optional) Behavioral autocorrelation

Uses Moran’s I to check clustering along the network.

---

# 5. SAOM Model — Network Evolution Only

## 5.1 Specify effects

```r
myeff <- getEffects(mydata)

myeff <- includeEffects(myeff, transTrip, cycle3)
myeff <- includeEffects(myeff, egoX, altX, sameX, interaction1="gender")
myeff <- includeEffects(myeff, X, interaction1="primary")
```

Interpretation:
- `transTrip` → transitivity (triadic closure)
- `sameX.gender` → gender homophily
- `X.primary` → tie formation for same-primary-school pairs

## 5.2 Algorithm settings

```r
myAlgorithm <- sienaAlgorithmCreate(
  projname="friends_res",
  nsub=4, n3=3000, seed=1908
)
```

## 5.3 Estimate model

```r
modelEv <- siena07(
  myAlgorithm,
  data=mydata, effects=myeff,
  returnDeps=TRUE,
  useCluster=TRUE, nbrNodes=4
)
```

---

# 6. Goodness of Fit (GOF)

Evaluate whether simulated networks match structural properties.

Examples:

```r
gofEvId <- sienaGOF(modelEv, varName="friendship", IndegreeDistribution)
plot(gofEvId)

gofEvTC <- sienaGOF(modelEv, varName="friendship", TriadCensus)
plot(gofEvTC)
```

Good fit: observed curve lies inside simulated envelope.

---

# 7. Network–Behavior Co-evolution (SAOM)

## 7.1 Add behavior as dependent variable

```r
delinquentbeh <- sienaDependent(delinquent, type="behavior")
mydata <- sienaDataCreate(friendship, delinquentbeh, gender, primary)
```

## 7.2 Friendship evolution effects

```r
myeff <- includeEffects(myeff, transTrip, cycle3, name="friendship")
myeff <- includeEffects(myeff, egoX, altX, sameX,
                        name="friendship", interaction1="gender")
myeff <- includeEffects(myeff, X,
                        name="friendship", interaction1="primary")
```

## 7.3 Behavioral evolution effects

Peer influence (average similarity):

```r
myeff <- includeEffects(myeff, outdeg, indeg, avSim,
                        name="delinquentbeh", interaction1="friendship")
```

## 7.4 Example hypotheses

### H5: “Students befriend others with similar delinquency”

Add similarity on delinquency:

```r
myeff <- includeEffects(myeff, simX,
                        name="friendship", interaction1="delinquency")
```

### H10: “Boys increase delinquency more than girls”

```r
myeff <- includeEffects(myeff, egoX,
                        name="delinquentbeh", interaction1="gender")
```

## 7.5 Estimate co-evolution model

```r
modelCoev <- siena07(
  myAlgorithm,
  data=mydata, effects=myeff,
  returnDeps=TRUE,
  useCluster=TRUE, nbrNodes=4
)
```

## 7.6 Co-evolution GOF

Friendship + behavior fit checks:

```r
gofCoevId  <- sienaGOF(modelCoev, varName="friendship", IndegreeDistribution)
gofCoevBeh <- sienaGOF(modelCoev, varName="delinquentbeh", BehaviorDistribution)

plot(gofCoevId)
plot(gofCoevBeh)
```

---

# 8. Interpretation of SAOM Parameters

## 8.1 Network evolution

- **Rate parameters**  
  Number of opportunities for actors to change ties.

- **Evaluation effects**  
  - `transTrip > 0` → actors form transitive ties  
  - `cycle3 > 0` → cyclic closure  
  - `sameX.gender > 0` → gender homophily  
  - `X.primary > 0` → same-school → more ties  

## 8.2 Behavior evolution

- `avSim > 0` → **peer influence** (behavioral convergence)  
- `egoX.gender > 0` → **boys more likely to increase delinquency**  

Effects are **nonlinear** and should be interpreted via simulation, not raw coefficients.

---

## Summary / Conclusion

### SAOM key insights from this practical:

#### 1. SAOMs model networks in *continuous time*
Changes are not wave-by-wave but via many micro-steps.

#### 2. Actors optimize an objective function
Each step increases $f_i(x)$.

#### 3. Separate *opportunities* and *preferences*
- Rate parameters: frequency of possible changes  
- Evaluation parameters: desirability of changes  

#### 4. Structural dependencies matter
Transitivity, cycles, homophily, and covariates shape tie formation.

#### 5. Behavior co-evolution captures peer influence
Networks affect behaviors, and behaviors affect networks.

#### 6. GOF is crucial
A converged model is not necessarily a good model.

#### 7. SAOMs provide a powerful framework
Ideal for studying:
- network evolution  
- social selection  
- behavioral contagion  
- peer influence dynamics  
- co-evolutionary systems  

 
