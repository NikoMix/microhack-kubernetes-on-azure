# B.2.1 Workload Assessment — evidence checklist

Audit control **B.2.1 — Workload Assessment** (Kubernetes on Microsoft Azure Advanced
Specialization, checklist V2.5.1).

## Audit requirement

- **3 unique customers**, each with Kubernetes-on-Azure work in the last 12 months.
- **2 artifacts per customer** demonstrating a real assessment.
- **Greenfield exception:** when the partner uses Kubernetes solely for greenfield workloads, a
  **Well-Architected Review (B.3.2)** is accepted as alternative evidence for B.2.1.

## Evidence items (tick before sign-off)

- [ ] Dependency map per workload: inbound callers, outbound dependencies, data stores,
      identities, external services (diagram + table).
- [ ] Container / AKS-readiness assessment across statelessness, containerisation, secrets,
      identity, networking, observability, data, resilience — each RAG-rated with evidence.
- [ ] Prioritised remediation backlog: item, severity, effort, target AKS feature, owner,
      acceptance test.
- [ ] Migration verdict per workload (Rehost / Replatform / Refactor) with rationale.
- [ ] Top blockers explicitly called out (in-cluster secrets, root containers, local state,
      single-provider AI lock-in).
- [ ] Anonymised (Customer A/B/C); no PII or customer IP.
- [ ] Filed in `Module B / B2.1 /` with naming `B2.1_<DocType>_<Customer>_v<N>.<ext>` and listed
      in the Evidence Index.

## Cross-references

- Feeds the **B.3.1 HLD** (`hld-generator` skill) — each remediation item maps to a design area.
- Blockers should appear as GitHub Issues labelled `module:b2.1`.
