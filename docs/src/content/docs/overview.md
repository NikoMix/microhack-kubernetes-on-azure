---
title: "Course overview"
description: >-
  Audience, outcomes, and how the MicroHack pieces fit together.
---

## What this MicroHack is

Kubernetes on Azure — Module B is a one-day, classroom-led Train-the-Trainer MicroHack for the full AKS engagement lifecycle: assess, design, deliver, validate, and operate. It maps directly to the seven Module B controls in the Kubernetes on Microsoft Azure Advanced Specialization.

You use a secure AKS baseline, a polyglot sample workload, Flux GitOps, and an AKS Engagement Copilot agent to produce the same evidence a partner team would collect during a customer engagement.

## Train-the-Trainer model

Each module keeps four artifacts in sync so trainers can teach, coach, and score consistently:

| Artifact | Purpose | Source |
| --- | --- | --- |
| Learner README | Runnable lab steps for attendees | [challenges](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/challenges) |
| Facilitator guide | Timing, talking points, pitfalls, demo-vs-drive advice | [challenge facilitator guides](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/challenges) |
| Trainer solutions | Reference outputs and scoring anchors | [trainer-only solutions folders](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/challenges) |
| Slides and docs | Classroom narrative and concise module reference | [slides](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/slides) and this site |

The docs pages summarise the learning path. The lab READMEs remain the source for copy-paste commands and evidence templates.

## Mixed-audience approach

The day is designed for a mixed cohort. Newer Kubernetes learners should start with the [Kubernetes and AKS primer](/references/primer/) and keep the [kubectl cheat sheet](/references/kubectl-cheat-sheet/) open. Experienced learners should use the stretch goals in each lab to deepen design, security, and operational trade-offs.

Facilitators should demo the first pass of unfamiliar tooling, then let learners drive with Copilot and MCP prompts. Keep evidence quality, not command memorisation, as the success measure.

## Module B control map

| Control | Module | Evidence theme |
| --- | --- | --- |
| B.1.1 | [M1 Foundations](/modules/m1-foundations/) | Two-FTE certification mapping and readiness plan |
| B.2.1 | [M2 Assessment](/modules/m2-assessment/) | Dependency map and prioritised remediation backlog |
| B.3.1 | [M3 Design](/modules/m3-design/) | Design document and architecture diagram |
| B.3.2 | [M3 Design](/modules/m3-design/) | Reliability and Security Well-Architected Review export |
| B.4.1 | [M4 Delivery](/modules/m4-delivery/) | Delivery evidence, as-built, and diagrams |
| B.5.1 | [M5 Validate](/modules/m5-validate/) | Test plan, results, performance evaluation, remediation log, sign-off |
| B.5.2 | [M6 Operate](/modules/m6-operate/) | CI/CD lifecycle, SLO/SLA tracking, runbook, currency, growth planning |

See the full [coverage map](/coverage-map/) for validation checkpoints.

## How to use this site

Start with the [agenda](/agenda/) to understand pacing. Use the module pages as facilitator-friendly summaries, then jump to the GitHub lab README when learners need runnable steps. Use the reference pages for just-in-time concept support, certification planning, Copilot/MCP usage, and terminology.

Source folders:

- [Challenges](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/challenges)
- [Slides](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/slides)
- [Trainer guide](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/trainer-guide)
