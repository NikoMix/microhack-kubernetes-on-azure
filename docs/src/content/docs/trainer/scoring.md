---
title: "Scoring rubric"
description: >-
  Per-module success criteria tied to Module B evidence.
---

This page mirrors the trainer scoring rubric. The full canonical file is in GitHub: [trainer-guide/scoring.md](https://github.com/NikoMix/microhack-kubernetes-on-azure/blob/main/trainer-guide/scoring.md).

## Overall rubric

| Result | Criteria |
| --- | --- |
| Pass | All controls have pass-level evidence, M5 includes customer sign-off, and M6 operations documentation references the delivered design and validation findings. |
| Partial | Most evidence is usable, but one or more artifacts need rework, or M5 sign-off is conditional with clear ownership. |
| Fail | Required artifacts are missing, evidence cannot be reviewed, M5 sign-off is absent or outputs do not map to Module B controls. |

## Evidence checklist

- [ ] B.1.1: 2-FTE certification mapping and readiness/study plan.
- [ ] B.2.1: Dependency map and prioritised remediation backlog.
- [ ] B.3.1: Design document and architecture diagram.
- [ ] B.3.2: Reliability and Security WAR export, rationale and backlog.
- [ ] B.4.1: At least two delivery artifacts plus logical, physical and sequence diagrams.
- [ ] B.5.1: Test plan, results, performance evaluation, remediation log and customer sign-off.
- [ ] B.5.2: CI/CD lifecycle, SLO/SLA tracking, triage runbook, platform-currency process, growth planning and Container Insights evidence.

## Module summary

| Module | Control | Pass evidence |
| --- | --- | --- |
| M0 | Environment readiness | Learner can run labs, subscription and region are known, and Copilot/MCP fallback is documented. |
| M1 | B.1.1 | Two named FTE roles map to appropriate certs, with a realistic readiness/study plan. |
| M2 | B.2.1 | Dependency map covers services, data, network, state and secrets; backlog is prioritised by effort and risk. |
| M3 | B.3.1 / B.3.2 | Design and diagram cover AKS design areas; WAR export covers Reliability and Security with rationale and backlog. |
| M4 | B.4.1 | Delivery artifacts and diagrams describe the actual or reference deployment. |
| M5 | B.5.1 | Validation evidence is complete and customer sign-off is present. |
| M6 | B.5.2 | Operations documentation covers lifecycle, SLOs, incidents, platform currency, growth and monitoring. |

## Gating evidence

M5 customer sign-off gates overall completion. Technical test output without sign-off is at best partial, because the control requires customer acceptance of the validation evidence.
