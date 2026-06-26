---
title: "One-day agenda"
description: >-
  Timeboxed run-of-day from 08:30 to 17:00 for the mixed cohort.
---

## Run of day

| Time | Slot | Duration | Control | Evidence focus |
| --- | --- | --- | --- | --- |
| 08:30 | Welcome and Train-the-Trainer orientation | 30 min | Orientation | Cohort split, scoring model, artifact flow, and how learners will use Copilot/MCP |
| 09:00 | [M0 · Setup and toolchain](/modules/m0-setup/) | 30 min | env | Working AKS context, reachable MCP servers, responding AKS Engagement Copilot |
| 09:30 | [M1 · Foundations and certification readiness](/modules/m1-foundations/) | 45 min | B.1.1 | Two-FTE certification mapping and readiness or study plan |
| 10:15 | [M2 · Workload assessment](/modules/m2-assessment/) | 60 min | B.2.1 | Dependency map and prioritised remediation backlog |
| 11:15 | [M3 · Solution design and WAR](/modules/m3-design/) | 90 min | B.3.1, B.3.2 | Design document, architecture diagram, Reliability and Security WAR export, prioritised backlog |
| 12:45 | Lunch | 45 min | Break | Trainers check evidence progress and identify learners needing support |
| 13:30 | [M4 · Delivery](/modules/m4-delivery/) | 90 min | B.4.1 | Delivery package, as-built, logical diagram, physical diagram, sequence diagram |
| 14:45 | Short break inside M4/M5 transition | 15 min | Break | Reset clusters, confirm GitOps state, queue validation tooling |
| 15:00 | [M5 · Validate and test](/modules/m5-validate/) | 60 min | B.5.1 | Test plan, results, performance evaluation, remediation log, customer sign-off |
| 16:00 | [M6 · Operate and document](/modules/m6-operate/) | 45 min | B.5.2 | CI/CD lifecycle, SLO/SLA tracking, triage runbook, platform currency, growth plan, dashboards and alerts |
| 16:45 | Wrap-up and evidence review | 15 min | All | Trainer scoring, learner reflection, hand-off actions, teardown reminder |
| 17:00 | End | — | — | Day closes |

## Mixed-cohort pacing

Keep newer learners moving by pointing them to the [primer](/references/primer/) before M1 and the [kubectl cheat sheet](/references/kubectl-cheat-sheet/) during labs. Pair newer learners with experienced Kubernetes practitioners for M2 through M5 evidence reviews.

Experienced learners should take stretch goals after their core evidence is accepted: deeper WAR rationale, stricter security controls, richer diagrams, or operational automation. Do not let stretch work delay the required evidence for the control.

## Facilitator checkpoints

- At the end of M1, confirm every team has two named FTE roles and target certifications.
- At the end of M2, confirm dependency maps include upstream, downstream, state, secrets, network, and data flows.
- Before lunch, confirm M3 has both design and WAR evidence, not just diagrams.
- Before M5, confirm GitOps deployment state is stable enough to test.
- During wrap-up, collect the B.5.2 operating documents and dashboard or alert references.
