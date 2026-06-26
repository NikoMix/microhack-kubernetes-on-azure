# M6 facilitator guide · Operate & document

Use this guide to keep the 45-minute operations lab focused on scored B.5.2 evidence.

## Timing breakdown

| Time | Activity | Facilitation notes |
| --- | --- | --- |
| 0-5 min | Frame day-2 operations | Explain that delivery is not complete until support documentation exists. |
| 5-11 min | CI/CD lifecycle | Demo the build→test→scan→sign→deploy→Flux reconcile flow, then have learners complete the narrative. |
| 11-18 min | SLO/SLA tracking | Drive a short discussion on SLIs, SLOs, SLAs, and error budgets. |
| 18-28 min | Triage runbook | Let learners draft Sev1/Sev2 and cluster triage steps with Copilot support. |
| 28-35 min | Platform currency | Demo Microsoft Docs MCP lookup for AKS support and upgrade guidance. |
| 35-40 min | Growth planning | Split newer and experienced learners; newer learners use the template, experienced learners add DR or cost depth. |
| 40-45 min | Container Insights and evidence review | Confirm dashboards, alert rules, and all five B.5.2 documents are present. |

## Talking points

- Post-deployment documentation is operational evidence, not paperwork.
- GitOps improves release traceability because the cluster reconciles from reviewed desired state.
- SLOs are internal reliability targets; SLAs are external commitments. Do not promise what telemetry cannot measure.
- Runbooks should include symptoms, commands, dashboards, mitigations, escalation, and recovery validation.
- AKS currency is a planned operating process. Unsupported versions, stale node images, and unpatched add-ons create delivery risk.
- Container Insights and Azure Monitor alerts should be actionable and tied to severity definitions.

## Common pitfalls and fixes

| Pitfall | Impact | Fix |
| --- | --- | --- |
| No error budgets | Teams cannot decide when reliability work should interrupt feature work. | Add a burn policy with review cadence and release freeze triggers. |
| Runbook lacks escalation paths | Responders know what to inspect but not who can approve mitigation. | Add primary owner, backup owner, communications channel, and escalation timeboxes. |
| Falling behind AKS support window | Urgent upgrades become risky and may block support cases. | Track supported minor versions monthly and reserve maintenance windows. |
| Alert fatigue | Responders ignore noisy alerts. | Alert on symptoms and sustained impact, not every transient pod restart. |
| Dashboards without owners | Views drift and no one trusts them. | Assign an owner and quarterly review date to each dashboard. |

## Demo-vs-drive guidance

Demo the first Copilot prompt and one Azure MCP lookup so the room sees how the `runbook` and `as-built` skills accelerate drafting. Then let learners drive their own documents. Intervene only when teams omit scored evidence or create alerts without clear action.

For newer learners, demo a simple `kubectl get nodes` and Container Insights query before asking them to write triage steps. For experienced learners, ask them to harden the documents with maintenance windows, DR assumptions, and cost thresholds.

## Cohort-split tips

- Pair newer learners with an experienced learner for the triage runbook.
- Give newer learners the Sev2 worked example as a pattern after they attempt the first draft.
- Ask experienced learners to challenge whether each alert maps to a user-impacting symptom.
- Rotate one learner per table into the role of incident commander during the runbook review.

## Evidence collected

Collect these artifacts for scoring against `../../trainer-guide/scoring.md`:

- CI/CD lifecycle document with build→test→scan→sign→deploy via Flux GitOps.
- SLO/SLA tracking document with SLIs, targets, error budgets, and cadence.
- Triage runbook with Sev1/Sev2, cluster procedures, and escalation.
- Platform-currency process covering AKS upgrades, node images, add-ons, and patches.
- Growth plan covering scaling, resilience, DR, observability growth, and cost.
- Container Insights dashboard and alert-rule evidence.
