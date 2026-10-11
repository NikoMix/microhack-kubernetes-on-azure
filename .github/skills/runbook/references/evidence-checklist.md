# B.5.2 Post-deployment Documentation — evidence checklist

Audit control **B.5.2 — Post-deployment Documentation** (checklist V2.5.1). Shared with the
`as-built` skill.

## Audit requirement

- **3 unique customers.**
- Evidence covers **CI/CD** and **post-deployment operations**: SLA/SLO, **triage**, and growth /
  platform currency.

## Evidence items (per customer)

- [ ] CI/CD documented (pipelines, gates, scans) — `.github/workflows/` is acceptable evidence.
- [ ] SLA / SLO record with dashboards and alert rules.
- [ ] **Triage runbooks** (detect → diagnose → mitigate → verify → rollback) for the top failure
      modes.
- [ ] **Cluster-lifecycle runbooks** (drain, node-image upgrade, control-plane upgrade,
      blue/green, secret rotation, cert renewal, restore drill).
- [ ] **Platform-currency plan** (K8s version policy, auto-upgrade channels, maintenance windows,
      deprecated-API tracking, dependency/image patch cadence with zero known vulns).
- [ ] **As-built** document (see `as-built` skill) reflecting deployed state.
- [ ] Anonymised; filed as `B5.2_<DocType>_<Customer>_v<N>.pdf` in the Evidence Index.

## Runbook quality bar

Each runbook includes prerequisites, blast radius, dry-run, rollback, observability checks,
customer comms, and sign-off.

## Cross-references

- Input: `test-plan` (B.5.1) SLOs, `war-runner` (B.3.2) risks. Pairs with `as-built` (B.4.1/B.5.2).
- Track gaps as GitHub Issues labelled `module:b5.2`.
