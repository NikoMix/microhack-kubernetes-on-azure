---
mode: agent
description: Drive Module M2 (B.2.1 Workload Assessment) — produce a dependency map and prioritised remediation backlog.
tools: ['codebase', 'search', 'fetch']
---

# Module M2 — Workload Assessment

## Goal

Assess the candidate workloads for AKS migration and produce evidence the engagement team performed a
structured discovery. This module maps 1:1 to Module B control **B.2.1 (Workload Assessment)**.

## Deliverable

- A dependency map of the in-scope workloads.
- A prioritised remediation backlog.

## Use the agent and skill

- Drive this lab with the **AKS Engagement Copilot** agent: [`.github/agents/aks-engagement-copilot.agent.md`](../agents/aks-engagement-copilot.agent.md).
- Run the assessment with the **Workload Assessment** skill: [`.github/skills/workload-assessment/SKILL.md`](../skills/workload-assessment/SKILL.md).

## Steps with Copilot

1. Ask Copilot to read [`challenges/02-assessment/README.md`](../../challenges/02-assessment/README.md)
   and the sample apps under [`apps/`](../../apps/) (dotnet-api, python-worker, node-web).
2. Invoke the Workload Assessment skill to inventory each app's runtime, dependencies, data stores,
   and external integrations.
3. Have Copilot generate a dependency map (services, data, ingress/egress, identity) for the polyglot
   estate.
4. Score each workload for migration readiness and risk, then derive a prioritised remediation
   backlog with effort and impact.
5. Export the dependency map and backlog into [`challenges/02-assessment/solutions/`](../../challenges/02-assessment/solutions/).

## MCP server calls

- `azure`: discover existing resources, dependencies, and configuration to ground the assessment.
- `microsoft.docs.mcp`: confirm AKS landing-zone and migration assessment guidance.
- `github`: file each backlog item as an issue and link it from the M2 lab issue.

## Validation / evidence

- [ ] Dependency map covers all in-scope workloads and their integrations.
- [ ] Remediation backlog is prioritised with risk, effort, and impact.
- [ ] Assessment artifacts saved under the assessment solutions folder.
- [ ] M2 lab issue references B.2.1 and links the evidence.
