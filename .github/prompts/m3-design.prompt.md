---
mode: agent
description: Drive Module M3 (B.3.1 Solution Design + B.3.2 Well-Architected Review) — produce an AKS HLD and WAR export.
tools: ['codebase', 'search', 'fetch']
---

# Module M3 — Solution Design & Well-Architected Review

## Goal

Design the AKS landing zone and validate it against the Well-Architected Framework. This module maps
1:1 to Module B controls **B.3.1 (Solution Design)** and **B.3.2 (Well-Architected Review)**.

## Deliverable

- An AKS landing-zone HLD covering all design areas.
- A WAR export assessing at least two pillars.

## Use the agent and skills

- Drive this lab with the **AKS Engagement Copilot** agent: [`.github/agents/aks-engagement-copilot.agent.md`](../agents/aks-engagement-copilot.agent.md).
- Generate the HLD with the **HLD Generator** skill: [`.github/skills/hld-generator/SKILL.md`](../skills/hld-generator/SKILL.md).
- Run the review with the **WAR Runner** skill: [`.github/skills/war-runner/SKILL.md`](../skills/war-runner/SKILL.md).

## Steps with Copilot

1. Ask Copilot to read [`challenges/03-design/README.md`](../../challenges/03-design/README.md) and the
   M2 assessment outputs.
2. Invoke the HLD Generator skill to produce a secure-baseline HLD: system + user node pools across
   AZs, Microsoft Entra ID + Azure RBAC for Kubernetes, Workload ID, Azure CNI Overlay, private
   cluster option, ACR with managed identity, Azure Firewall egress, App Gateway for Containers /
   managed NGINX ingress, Defender for Containers, Azure Policy for AKS + Deployment Safeguards, Key
   Vault + CSI Secret Store, Azure Monitor / Container Insights, and Managed Prometheus + Grafana.
3. Map the HLD to the reference IaC under [`infra/bicep`](../../infra/bicep) and
   [`infra/terraform`](../../infra/terraform) (AVM secure baseline).
4. Invoke the WAR Runner skill and complete at least two pillars (for example Security and
   Reliability), capturing recommendations and an action list.
5. Export the HLD and WAR results into [`challenges/03-design/solutions/`](../../challenges/03-design/solutions/).

> Optional AI add-on: if the design includes an AI capability, it must use the modular inference
> provider abstraction (`AI_PROVIDER` in `{foundry, azure-openai, github-models}`). Never hard-code a
> provider or key, and no image generation.

## MCP server calls

- `microsoft.docs.mcp`: pull AKS landing-zone design areas and Well-Architected guidance.
- `azure`: validate region capabilities, SKUs, and policy availability in `westeurope`.
- `github`: track design decisions and WAR actions in the M3 lab issue.

## Validation / evidence

- [ ] HLD covers all landing-zone design areas with the secure-baseline components.
- [ ] WAR export assesses at least two pillars with prioritised recommendations.
- [ ] HLD traces to the AVM IaC under `infra/`.
- [ ] M3 lab issue references B.3.1 and B.3.2 and links the evidence.
