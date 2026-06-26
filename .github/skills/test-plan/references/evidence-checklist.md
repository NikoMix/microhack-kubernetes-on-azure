# B.5.1 Service Validation & Testing — evidence checklist

Audit control **B.5.1 — Service Validation and Testing** (checklist V2.5.1).

## Audit requirement

- **3 unique customers.**
- **Customer sign-off is mandatory** — a tested workload without signed acceptance fails B.5.1.

## Evidence items (per customer)

- [ ] SLIs/SLOs defined with targets and measurement source.
- [ ] Load-test plan (scenarios, VUs, duration, thresholds) — Azure Load Testing.
- [ ] Chaos/resilience experiments (hypothesis, blast radius, abort, steady-state) — Chaos Studio.
- [ ] Executed results with **measured-vs-target SLO comparison** + dashboards/exports.
- [ ] Issues opened for SLO misses with remediation owners.
- [ ] **Signed customer acceptance** (results summary, accepted risks, signatures).
- [ ] Anonymised; filed as `B5.1_<DocType>_<Customer>_v<N>.pdf` in the Evidence Index.

## Hard gate

The **sign-off** (`assets/signoff-template.md`) is the most-failed item — generate it early and
chase the customer signature. Track as a GitHub Issue labelled `module:b5.1` until signed.

## Cross-references

- Input: deployed baseline from `as-built` (B.4.1). SLO misses feed `runbook` (B.5.2).
