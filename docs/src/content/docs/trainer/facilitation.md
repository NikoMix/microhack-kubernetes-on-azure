---
title: "Facilitation"
description: >-
  Teaching techniques and demo-vs-drive guidance.
---

This page mirrors the trainer facilitation guide. The full canonical file is in GitHub: [trainer-guide/facilitation.md](https://github.com/NikoMix/microhack-kubernetes-on-azure/blob/main/trainer-guide/facilitation.md).

## Facilitation stance

Teach as an AKS engagement lead. Start each module with its Module B control and evidence target, explain why the task matters in a customer engagement, and keep Copilot/MCP use visible, verified and optional.

## Mixed-cohort techniques

| Cohort need | Trainer move |
| --- | --- |
| Newer Kubernetes or AKS learners | Use primers, cheat sheets, pairing and Copilot explanations before commands. |
| Experienced learners | Assign stretch goals that improve evidence quality rather than unrelated work. |
| Trainers learning to redeliver | Narrate why you demo, when you let learners drive and how you score evidence. |

## Demo-vs-drive rules

Demo when a mistake would block the room, introduce a difficult mental model or recover a shared failure. Let learners drive when the work requires judgement, artifact ownership or interpretation of evidence.

## Copilot and MCP live

Name the skill and MCP server, show the prompt, inspect the output for assumptions, verify concrete values in Azure or GitHub, and then convert the response into a learner-owned artifact. If the AKS Engagement Copilot, a WS4 skill or an MCP server is unavailable, use the manual lab path.

## Questioning patterns

Ask questions that test evidence quality:

- What control are we proving?
- Which Copilot assumption must we verify?
- What dependency would break the service first?
- Which design trade-off did you choose and why?
- Would a customer sign this validation result?
- Who owns this runbook action during a Sev1?

## Certification-readiness discussion

For B.1.1, require two named FTE roles, target certifications and a practical study plan. Include CKA, CKAD, optional CKS and Red Hat OpenShift EX280 or DO280 where relevant. Treat skill gaps as delivery risks with mitigations.
