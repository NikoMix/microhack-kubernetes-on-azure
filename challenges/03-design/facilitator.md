# M03 facilitator guide

Use this guide to keep the design lab practical, evidence-focused, and aligned to B.3.1 and B.3.2 scoring.

## Timing breakdown

| Time | Activity | Facilitation notes |
| --- | --- | --- |
| 0-5 min | Frame the lab | Restate the M2 inputs and the evidence required for B.3.1 and B.3.2. |
| 5-15 min | Primer and reference architecture | Explain HLDs, landing zones, AKS secure baseline, and why the Well-Architected Review is not a paperwork exercise. |
| 15-30 min | Gather inputs | Learners collect M2 assessment outputs, requirements, constraints, and Azure environment values. |
| 30-50 min | HLD design areas | Learners drive `hld-generator`; facilitator checks that all 14 design areas are represented. |
| 50-55 min | Short break | Keep the break short so the review has enough time. |
| 55-68 min | Diagram, cluster design, and network design | Learners adapt the Mermaid diagram and complete the two supporting templates. |
| 68-82 min | Well-Architected Review | Learners run `war-runner` for Reliability and Security, then capture rationale and severity. |
| 82-90 min | Evidence review and scoring handoff | Confirm files exist, backlog is prioritised, and artifacts are ready for trainer scoring. |

## Talking points by design area

- IAM/RBAC with Microsoft Entra ID: distinguish human access, Azure resource permissions, and workload-to-Azure access; prefer Entra ID, Azure RBAC, Workload Identity, and least privilege.
- Network architecture: explain hub/spoke, private-cluster option, ingress choices, firewall egress, UDRs, Azure CNI Overlay, and DNS dependencies.
- Security: position Defender for Containers, Azure Policy for AKS, and Deployment Safeguards as preventive and detective controls.
- Governance and cost: connect Log Analytics retention, budgets, tags, policy assignments, and cost ownership.
- Backup and business continuity: clarify that AKS control plane and etcd are Microsoft-managed; learner design must still cover cluster state, manifests, stateful data, and regional recovery assumptions.
- Regulatory compliance: keep `westeurope` data residency explicit and map controls to policy initiatives, CIS benchmarks, and AKS baseline guidance.
- Cluster RBAC: separate Kubernetes roles and bindings from Azure RBAC; enforce namespace tenancy.
- Continuous image vulnerability scanning: use Defender and ACR scanning signals; describe admission gating for critical vulnerabilities.
- Requests, limits, namespaces, ResourceQuotas, and LimitRanges: turn capacity assumptions into guardrails.
- Monitoring and alerting: include Container Insights, Managed Prometheus, Grafana, alert rules, and actionable ownership.
- Probes: require liveness, readiness, and startup probes that align with the apps' `/health` endpoints.
- Secrets in Key Vault: use CSI Secret Store with rotation; do not store secrets in images, manifests, or environment defaults.
- Cluster design document: record node pools, sizing, zones, upgrade strategy, autoscaling, maintenance windows, and add-ons.
- Network design document: record address spaces, subnets, peering, firewall rules, ingress paths, egress paths, DNS, and private endpoints.

## Common pitfalls and fixes

- Skipping areas: use the 14-area checklist before learners begin the WAR.
- Over-engineering: ask which customer requirement each decision satisfies; defer speculative features to the backlog.
- Confusing Azure RBAC and cluster RBAC: draw three lanes for Azure management plane, Kubernetes API permissions, and workload identity.
- Ingress and egress confusion: have learners trace one browser request and one outbound dependency through the diagram.
- Treating the WAR as a score only: require rationale, severity, recommendation, and backlog priority.
- Hard-coding environment names: use contract placeholders unless Azure MCP has read real deployed values.
- Missing data protection: require stateful data ownership even when workloads are mostly stateless.

## Demo-vs-drive guidance

Demo the first `hld-generator` prompt and show how to challenge Copilot when a design area is thin. Then let learners drive each section. Demo one WAR finding end to end, including severity and backlog translation, then let learners complete the remaining findings.

If the Copilot skills are unavailable, demo how to use the templates manually and ask learners to cite Microsoft Docs MCP guidance in the decision notes.

## Cohort-split tips

- Newer learners: pair them with a facilitator or experienced learner, keep them focused on the template prompts, and ask them to explain traffic flow in plain language.
- Experienced learners: assign the private-cluster plus App Gateway for Containers stretch goal, require a stricter admission-gating story, or ask them to compare managed NGINX with App Gateway for Containers.
- Mixed tables: make one person own identity, one own networking, one own operations, and one own WAR backlog quality.

## Evidence collected

Collect the learner evidence and score it with [trainer scoring](../../trainer-guide/scoring.md).

- B.3.1 design document covering all 14 areas.
- B.3.1 architecture diagram.
- B.3.1 cluster design document.
- B.3.1 network design document.
- B.3.2 WAR export for Reliability and Security.
- B.3.2 pillar rationale.
- B.3.2 prioritised backlog.
