---
mode: agent
description: Drive Module M6 (B.5.2 Post-deployment Documentation) — produce CI/CD, SLO, triage runbook, and platform currency docs.
tools: ['codebase', 'search', 'fetch']
---

# Module M6 — Operate & Post-deployment Documentation

## Goal

Hand the platform to operations with complete documentation. This module maps 1:1 to Module B control
**B.5.2 (Post-deployment Documentation)**.

## Deliverable

- CI/CD documentation.
- SLO documentation.
- A triage runbook.
- A platform-currency plan.

## Use the agent and skills

- Drive this lab with the **AKS Engagement Copilot** agent: [`.github/agents/aks-engagement-copilot.agent.md`](../agents/aks-engagement-copilot.agent.md).
- Build the runbook with the **Runbook** skill: [`.github/skills/runbook/SKILL.md`](../skills/runbook/SKILL.md).
- Finalize the as-built with the **As-Built** skill: [`.github/skills/as-built/SKILL.md`](../skills/as-built/SKILL.md).

## Steps with Copilot

1. Ask Copilot to read [`challenges/06-operate/README.md`](../../challenges/06-operate/README.md) and
   the M4 as-built.
2. Document the CI/CD and GitOps flow (from [`gitops/`](../../gitops/) and [`scripts/`](../../scripts/))
   including promotion and rollback.
3. Document SLOs, alerting, and dashboards (Azure Monitor, Managed Prometheus + Grafana).
4. Invoke the Runbook skill to produce a triage runbook for common incidents (node, pod, ingress,
   identity, policy).
5. Produce a platform-currency plan (AKS version skew, node image upgrades, add-on and dependency
   updates), then export everything into
   [`challenges/06-operate/solutions/`](../../challenges/06-operate/solutions/).

> Any operational AI tooling must use the modular inference provider abstraction (`AI_PROVIDER` in
> `{foundry, azure-openai, github-models}`). Never hard-code a provider or key, and no image
> generation.

## MCP server calls

- `azure`: confirm monitoring, alerting, and current AKS/add-on versions.
- `microsoft.docs.mcp`: pull AKS upgrade, support-policy, and operations guidance.
- `github`: link runbook and currency-plan evidence in the M6 lab issue.

## Validation / evidence

- [ ] CI/CD documentation describes the GitOps pipeline with rollback.
- [ ] SLO documentation lists targets, alerts, and dashboards.
- [ ] Triage runbook covers the common incident classes.
- [ ] Platform-currency plan defines the upgrade and patch cadence.
- [ ] M6 lab issue references B.5.2 and links the evidence.
