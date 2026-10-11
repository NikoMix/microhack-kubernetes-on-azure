---
mode: agent
description: Drive Module M0 (env control) — bootstrap the Azure landing zone, dev container, and repo tour.
tools: ['codebase', 'search', 'fetch']
---

# Module M0 — Setup & Landing-Zone Bootstrap

## Goal

Get every trainer to a working baseline: authenticated Azure context, validated quota, a running dev
container, and a confident tour of the repo. This module maps to the **env** setup control (the
prerequisite gate before any Module B audit control).

## Deliverable

- Azure login + quota preflight passing for the target subscription and region (default `westeurope`).
- Dev container built and attached.
- A short repo-tour note proving you can navigate `challenges/`, `infra/`, `scripts/`, `apps/`,
  `gitops/`, `docs/`, and `slides/`.

## Use the agent and skill

- Drive this lab with the **AKS Engagement Copilot** agent: [`.github/agents/aks-engagement-copilot.agent.md`](../agents/aks-engagement-copilot.agent.md).
- No Module B skill is required for setup, but skim [`.github/skills/workload-assessment/SKILL.md`](../skills/workload-assessment/SKILL.md)
  so you know where M2 begins.

## Steps with Copilot

1. Ask Copilot to read [`challenges/00-setup/README.md`](../../challenges/00-setup/README.md) and
   summarize the prerequisites and exit criteria.
2. Run the preflight script in [`scripts/`](../../scripts/) (for example `scripts/preflight`) and ask
   Copilot to interpret any quota or RBAC gaps.
3. Open the repository in the dev container and confirm `kubectl`, `az`, and `bicep`/`terraform`
   tooling resolve on the path.
4. Ask Copilot for a guided tour of the repo layout, then have it produce a one-paragraph orientation
   note you can paste into your lab issue.
5. Confirm the default region and subscription are set, then record them as lab variables.

## MCP server calls

- `azure`: confirm the signed-in account, list subscriptions, and check compute/network quota in
  `westeurope`.
- `microsoft.docs.mcp`: look up current AKS prerequisites and supported region guidance.
- `github`: open the M0 lab issue from the template and link your evidence.

## Validation / evidence

- [ ] Preflight script output attached showing login + quota pass.
- [ ] Dev container terminal shows `az`, `kubectl`, and IaC tooling versions.
- [ ] Subscription ID and region recorded as lab variables.
- [ ] Repo-tour note linked in the M0 lab issue.
