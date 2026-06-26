# Service Validation & Test Plan — &lt;Customer A&gt;

> B.5.1 evidence. Export as `B5.1_TestPlan_CustomerA_v1.pdf`.

## 1. Scope & SLOs

| SLI | Target (SLO) | Measurement source |
|---|---|---|
| Availability | 99.9% | App Gateway / Container Insights |
| Latency p95 | &lt; 300 ms | Managed Prometheus |
| Error rate | &lt; 0.5% | Container Insights |
| Saturation (CPU/mem) | &lt; 70% | Managed Prometheus |

## 2. Load tests (Azure Load Testing)

| Scenario | Profile | VUs | Duration | Pass/fail threshold |
|---|---|---|---|---|
| Steady | constant | | 15 min | p95 &lt; SLO, errors &lt; SLO |
| Ramp | step | | 20 min | autoscale stabilises |
| Soak | constant | | 2 h | no leak / drift |
| Spike | burst | | 10 min | recovers &lt; 2 min |

## 3. Chaos experiments (Azure Chaos Studio)

| Experiment | Hypothesis (steady-state) | Blast radius | Abort condition |
|---|---|---|---|
| Pod kill | Replicas absorb loss, no SLO breach | 1 namespace | error rate &gt; 5% |
| Node drain | PDB keeps min replicas | 1 node | unavailable &gt; 1 min |
| AZ outage | Multi-AZ keeps service | 1 zone | availability &lt; SLO |
| Dependency fault | Retries/circuit-breaker hold | 1 dependency | cascading failure |
| Image-pull failure | Existing pods unaffected | 1 deployment | rollout blocked |

## 4. Results — measured vs target

| SLI | Target | Measured | Pass? | Evidence link |
|---|---|---|---|---|
| | | | | |

## 5. Issues raised

| Issue | SLO impacted | Severity | Owner | Status |
|---|---|---|---|---|

## 6. Pre-flight safety

- [ ] Runs against non-prod overlay
- [ ] PDBs + autoscaling in place
- [ ] Abort / rollback defined
- [ ] Customer informed of test window
