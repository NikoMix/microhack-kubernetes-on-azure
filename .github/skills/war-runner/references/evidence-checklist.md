# B.3.2 Well-Architected Review — evidence checklist

Audit control **B.3.2 — Azure Well-Architected Review** (checklist V2.5.1).

## Audit requirement

- **3 workloads** reviewed.
- **≥2 WAF pillars exported per workload** (assessment export or equivalent findings document).
- May serve as **alternative evidence for B.2.1** in greenfield-only scenarios.

## Evidence items (per workload)

- [ ] Scope statement: workload, reference architecture, two pillars chosen.
- [ ] Pillar 1 findings document with score, RAG-rated checks, and recommendations.
- [ ] Pillar 2 findings document (same structure).
- [ ] Prioritised improvement backlog (risk × effort) mapped to AKS features and repo paths.
- [ ] Top risk register (feeds B.5.2 runbooks).
- [ ] Anonymised; filed as `B3.2_WellArchitectedReview_<Customer>_<Pillar>_v<N>.pdf` in the
      Evidence Index.

## Pillar selection guidance (AKS)

- **Default:** Reliability + Security.
- **GitOps-led engagement:** Reliability + Operational Excellence.
- Performance Efficiency and Cost Optimization are valid but secondary for this course.

## Cross-references

- Input: `hld-generator` (B.3.1). Output: improvement backlog → `runbook` (B.5.2) + GitHub Issues
  labelled `module:b3.2`.
