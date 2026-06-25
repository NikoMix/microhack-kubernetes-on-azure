# Scoring rubric

Use this rubric to score the Module B evidence produced during the MicroHack. The rubric is intentionally evidence-based: a team passes by producing reviewable artifacts that map to the controls.

## Scoring principles

- Score the artifact, not the personality or seniority of the team.
- Require concrete evidence for each control.
- Accept manual outputs when Copilot or MCP is unavailable, as long as the evidence contract is met.
- Treat M5 customer sign-off as gating evidence for overall completion.
- Use partial when the artifact exists but lacks depth, traceability or customer readiness.

## Overall completion rubric

| Result | Criteria |
| --- | --- |
| Pass | All controls have pass-level evidence, M5 includes customer sign-off, and M6 operating documentation references the delivered design and validation findings. |
| Partial | Most controls have usable evidence, but one or more artifacts need rework, or M5 sign-off is conditional with clear remediation ownership. |
| Fail | Required artifacts are missing, evidence cannot be reviewed, M5 customer sign-off is absent, or outputs do not map to the Module B controls. |

## Evidence-collection checklist

- [ ] B.1.1: 2-FTE certification mapping with named roles and target certs.
- [ ] B.1.1: Readiness/study plan covering gaps, timeline and practice approach.
- [ ] B.2.1: Dependency map covering upstream/downstream services, data flows, network, state and secrets.
- [ ] B.2.1: Prioritised remediation backlog with effort and risk.
- [ ] B.3.1: Design document covering all required AKS design areas.
- [ ] B.3.1: Architecture diagram that matches the design narrative.
- [ ] B.3.2: Well-Architected Review export for Reliability and Security.
- [ ] B.3.2: WAR pillar rationale and prioritised backlog.
- [ ] B.4.1: At least two delivery artifacts from SOW, design, project plan, architecture diagram or as-built.
- [ ] B.4.1: Logical, physical and sequence diagrams.
- [ ] B.5.1: Test plan covering functional, integration, performance, resilience/chaos and security tests.
- [ ] B.5.1: Test results and performance evaluation.
- [ ] B.5.1: Remediation log.
- [ ] B.5.1: Customer sign-off.
- [ ] B.5.2: CI/CD lifecycle documentation from build to GitOps deploy.
- [ ] B.5.2: SLO/SLA tracking.
- [ ] B.5.2: Sev1/Sev2 and cluster triage runbook.
- [ ] B.5.2: Platform-currency process for AKS, node images, add-ons and patches.
- [ ] B.5.2: Growth planning.
- [ ] B.5.2: Container Insights dashboard or alert evidence.

## M0 - Setup

Facilitator guide: [M0 setup](../challenges/00-setup/facilitator.md).

| Control | Required evidence artifacts | Pass | Partial | Fail |
| --- | --- | --- | --- | --- |
| Environment readiness | Tool versions, Azure subscription context, AKS context status if available, Copilot/MCP reachability notes | Learner can run the labs, subscription and region are known, and fallback path is documented for unavailable Copilot/MCP assets. | Most tools work, but one non-critical tool or MCP server needs partner or trainer support. | Learner cannot access Azure or core tooling, and no viable partner or trainer environment is available. |

## M1 - Foundations and certification readiness (B.1.1)

Facilitator guide: [M1 foundations](../challenges/01-foundations/facilitator.md).

| Control | Required evidence artifacts | Pass | Partial | Fail |
| --- | --- | --- | --- | --- |
| B.1.1 | 2-FTE certification mapping with named roles and target certs | Two real delivery roles are mapped to appropriate certs, including CKA, CKAD, optional CKS or Red Hat OpenShift EX280/DO280 where relevant. | Roles or certs are present but rationale is thin or one role is generic. | Mapping is missing, has fewer than two FTE roles or lists certs without role fit. |
| B.1.1 | Readiness/study plan | Plan includes current gap, target, timeline, study activities, practice labs and mentoring or assessment checkpoint. | Plan exists but lacks timeline, practice detail or ownership. | Plan is missing or not connected to the certification mapping. |

## M2 - Workload assessment (B.2.1)

Facilitator guide: [M2 assessment](../challenges/02-assessment/facilitator.md).

| Control | Required evidence artifacts | Pass | Partial | Fail |
| --- | --- | --- | --- | --- |
| B.2.1 | Dependency map | Map covers upstream/downstream services, data flows, network paths, state and secrets, with risks visible. | Map covers the obvious services but misses one or more required dimensions. | Map is missing or too vague to guide migration or design. |
| B.2.1 | Prioritised remediation backlog | Backlog is prioritised and includes effort, risk, owner or next action. | Backlog exists but prioritisation or effort/risk is incomplete. | Backlog is missing or not traceable to assessment findings. |

## M3 - Solution design (B.3.1 / B.3.2)

Facilitator guide: [M3 design](../challenges/03-design/facilitator.md).

| Control | Required evidence artifacts | Pass | Partial | Fail |
| --- | --- | --- | --- | --- |
| B.3.1 | Design document | Covers identity, network, ingress, secrets, GitOps, observability, security, resilience, operations and known trade-offs. | Design exists but misses one or two areas or lacks trade-off rationale. | Design is missing, generic or not AKS-specific. |
| B.3.1 | Architecture diagram | Diagram aligns with the design and shows key Azure/AKS components and flows. | Diagram exists but omits important flows or does not fully match the narrative. | Diagram is missing or misleading. |
| B.3.2 | WAR export for Reliability and Security | Export includes both pillars with rationale, risks and decisions. | Export covers both pillars but rationale is thin or incomplete. | WAR export is missing or covers the wrong pillars. |
| B.3.2 | WAR prioritised backlog | Findings are prioritised and connected to design or delivery actions. | Backlog exists but lacks priority or actionability. | Backlog is missing or not tied to WAR findings. |

## M4 - Delivery (B.4.1)

Facilitator guide: [M4 delivery](../challenges/04-delivery/facilitator.md).

| Control | Required evidence artifacts | Pass | Partial | Fail |
| --- | --- | --- | --- | --- |
| B.4.1 | At least two of SOW, design, project plan, architecture diagram or as-built | Two or more artifacts are complete enough for customer review and align with the delivered or reference deployment. | Two artifacts exist but need more detail, or only one strong artifact is present with a clear recovery plan. | Fewer than two artifacts are available or artifacts do not describe the delivery. |
| B.4.1 | Logical, physical and sequence diagrams | All three diagram types exist and explain application, platform and deployment flow. | One diagram is weak or incomplete, but the delivery can still be understood. | Diagrams are missing or do not match the implementation. |
| B.4.1 | As-built or delivery narrative | Output records actual resource names or placeholders, deployment sequence, GitOps state and known deviations. | Narrative exists but misses deviations or reconciliation state. | No as-built or delivery narrative is present. |

## M5 - Service validation and testing (B.5.1)

Facilitator guide: [M5 validate](../challenges/05-validate/facilitator.md).

M5 customer sign-off is gating evidence. A team cannot receive an overall pass without it.

| Control | Required evidence artifacts | Pass | Partial | Fail |
| --- | --- | --- | --- | --- |
| B.5.1 | Test plan | Covers functional, integration, performance, resilience/chaos and security testing with expected outcomes. | Test plan exists but one test category is weak or missing. | Test plan is missing or only lists ad hoc checks. |
| B.5.1 | Results and performance evaluation | Results are captured, performance is evaluated against stated expectations, and failures are explained. | Results exist but performance thresholds or interpretation are incomplete. | Results are missing or cannot be tied to the test plan. |
| B.5.1 | Remediation log | Failures and risks are logged with owner, priority and next step. | Log exists but ownership or priority is incomplete. | Remediation findings are missing or ignored. |
| B.5.1 | Customer sign-off | Customer or trainer-customer signs off based on evidence, with conditions recorded if any. | Conditional sign-off exists with clear remediation owner and date. | Sign-off is absent. This blocks overall pass. |

## M6 - Operate (B.5.2)

Facilitator guide: [M6 operate](../challenges/06-operate/facilitator.md).

| Control | Required evidence artifacts | Pass | Partial | Fail |
| --- | --- | --- | --- | --- |
| B.5.2 | CI/CD lifecycle doc | Documents build, test, scan, sign and GitOps deploy flow. | Lifecycle exists but one stage lacks detail or ownership. | Lifecycle doc is missing or not connected to the delivered app. |
| B.5.2 | SLO/SLA tracking | Defines service objectives, indicators, targets and review cadence. | SLO/SLA tracking exists but thresholds or review cadence are incomplete. | SLO/SLA tracking is missing. |
| B.5.2 | Triage runbook | Covers Sev1/Sev2 and cluster triage with commands, owners and escalation. | Runbook exists but lacks severity clarity or ownership. | Runbook is missing or not actionable. |
| B.5.2 | Platform-currency process | Covers AKS upgrades, node images, add-ons and patches. | Process exists but lacks cadence, risk controls or owner. | Currency process is missing. |
| B.5.2 | Growth planning | Addresses scaling, capacity, cost and future workload onboarding. | Growth plan exists but is not tied to observed validation or design data. | Growth planning is missing. |
| B.5.2 | Container Insights dashboards and alerts | Monitoring evidence shows dashboards or alerts that support operations. | Evidence exists but alert/action mapping needs work. | No observability evidence is provided. |

## Scoring workflow for trainers

1. During each module, spot-check one artifact per team.
2. At each handoff, mark pass, partial or fail for the module evidence.
3. Before M5 sign-off, verify M2 and M3 risks are represented in the test plan or remediation log.
4. Before wrap, confirm M6 operations artifacts reference the delivered design and M5 validation results.
5. Record final completion as pass, partial or fail using the overall completion rubric.
