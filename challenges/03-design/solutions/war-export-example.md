# Well-Architected Review export example

This trainer-only example covers B.3.2 for Reliability and Security only.

## Review scope

| Item | Value |
| --- | --- |
| Workload | WS2 polyglot application on AKS |
| Landing zone | WS1 AKS secure baseline in West Europe |
| Pillars reviewed | Reliability and Security |
| Inputs | M2 assessment, HLD, architecture diagram, cluster design document, network design document |
| Reviewer | Trainer reference |

## Reliability rationale

The design meets the baseline reliability expectation because it uses zonal node pools, autoscaling, health probes, monitoring, planned maintenance, and redeployable GitOps manifests. Residual risk remains around stateful data recovery, restore testing, and explicit service-level objectives. The reliability backlog therefore prioritises backup validation, disruption budgets, alert actionability, and upgrade rehearsal.

## Reliability findings

| ID | Finding | Severity | Recommendation |
| --- | --- | --- | --- |
| REL-001 | Stateful data ownership and recovery objectives are not confirmed for all services. | High | Identify persistent volumes and external data stores, then define RPO, RTO, backup owner, and restore test cadence. |
| REL-002 | Pod disruption budgets are required for `node-web` and `dotnet-api` before production upgrades. | Medium | Add PDBs aligned to replica count and availability targets. |
| REL-003 | Alert rules exist conceptually but need tested action groups and runbook links. | Medium | Create alert rules with owners, severity, and M6 runbook references. |
| REL-004 | Startup and readiness timings need validation under cold start and downstream dependency delay. | Low | Exercise probes during M5 validation and tune thresholds. |

## Security rationale

The design aligns strongly to the Security pillar because identity is Entra-integrated, workload access uses Workload Identity, images are scanned, secrets use Key Vault CSI, and Defender plus Azure Policy provide preventive and detective controls. The remaining risk is enforcement maturity: admission gating, least-privilege review, and firewall rule minimisation must be proven before production.

## Security findings

| ID | Finding | Severity | Recommendation |
| --- | --- | --- | --- |
| SEC-001 | Critical image vulnerability gating is described but not yet enforced. | High | Implement admission or GitOps policy that blocks critical vulnerabilities and unapproved registries. |
| SEC-002 | Azure RBAC and Kubernetes RBAC mappings need named Entra groups and access review cadence. | High | Define groups, role assignments, RoleBindings, break-glass process, and quarterly access review. |
| SEC-003 | Firewall egress rules need least-privilege FQDN and service-tag review. | Medium | Replace broad outbound allowances with approved dependencies and owner-reviewed exceptions. |
| SEC-004 | Key Vault rotation behaviour must be demonstrated for each app. | Medium | Validate CSI rotation and restart or refresh behaviour during M5. |
| SEC-005 | Private-cluster option is deferred for the base class path. | Low | Record production criteria for private API server and private endpoints. |

## Prioritised backlog

| ID | Pillar | Finding | Severity | Recommendation | Effort | Priority | Owner | Status |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| WAR-001 | Reliability | Stateful data ownership and recovery objectives are not confirmed. | High | Define RPO, RTO, backup scope, and restore test for persistent volumes and external data stores. | M | P1 | Platform lead | Open |
| WAR-002 | Security | Critical image vulnerability gating is not enforced. | High | Add admission or GitOps policy that blocks critical vulnerabilities and unapproved registries. | M | P1 | Security lead | Open |
| WAR-003 | Security | RBAC mappings lack named Entra groups and review cadence. | High | Document Azure RBAC, Kubernetes RBAC, break-glass, and access review process. | S | P1 | Platform lead | Open |
| WAR-004 | Reliability | Pod disruption budgets are missing for user-facing services. | Medium | Add PDBs for `node-web` and `dotnet-api`, then test rolling upgrades. | S | P2 | App lead | Open |
| WAR-005 | Security | Egress rules need least-privilege review. | Medium | Replace broad rules with approved FQDNs, service tags, and exception owners. | M | P2 | Network lead | Open |
| WAR-006 | Reliability | Alerts need action groups and runbook links. | Medium | Create actionable alerts for node, pod, ingress, egress, and application health. | S | P2 | Operations lead | Open |
| WAR-007 | Security | Key Vault CSI rotation is not proven. | Medium | Demonstrate secret rotation and workload refresh in M5 validation. | S | P2 | App lead | Open |
| WAR-008 | Reliability | Probe thresholds need cold-start validation. | Low | Test liveness, readiness, and startup probes under dependency delay. | S | P3 | App lead | Open |
| WAR-009 | Security | Private-cluster criteria are deferred. | Low | Record when production requires private API server and private endpoints. | S | P3 | Architect | Open |
