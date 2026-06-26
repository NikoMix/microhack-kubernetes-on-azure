---
mode: agent
description: Drive Module M4 (B.4.1 Delivery) — deploy the AKS secure baseline, migrate apps via GitOps, and produce an as-built.
tools: ['codebase', 'search', 'fetch']
---

# Module M4 — Delivery

## Goal

Deliver the designed solution: stand up the AKS secure baseline, migrate the polyglot apps through
GitOps, and capture an as-built. This module maps 1:1 to Module B control **B.4.1 (Delivery)**.

## Deliverable

- A deployed AKS secure baseline.
- The polyglot apps migrated via GitOps.
- An as-built document.

## Use the agent and skill

- Drive this lab with the **AKS Engagement Copilot** agent: [`.github/agents/aks-engagement-copilot.agent.md`](../agents/aks-engagement-copilot.agent.md).
- Generate the as-built with the **As-Built** skill: [`.github/skills/as-built/SKILL.md`](../skills/as-built/SKILL.md).

## Steps with Copilot

1. Ask Copilot to read [`challenges/04-delivery/README.md`](../../challenges/04-delivery/README.md) and
   the M3 HLD.
2. Deploy the secure baseline from [`infra/bicep`](../../infra/bicep) or
   [`infra/terraform`](../../infra/terraform) using the deploy script in [`scripts/`](../../scripts/).
3. Bootstrap GitOps with `scripts/bootstrap-gitops` and confirm the
   [`gitops/clusters/microhack`](../../gitops/clusters/microhack),
   [`gitops/infrastructure`](../../gitops/infrastructure), and [`gitops/apps`](../../gitops/apps)
   trees reconcile.
4. Migrate the apps under [`apps/`](../../apps/) (dotnet-api .NET 10, python-worker Python 3.14
   FastAPI, node-web Node 24 Fastify) through the GitOps pipeline.
5. Invoke the As-Built skill to capture the deployed topology, identities, networking, and policy
   posture into [`challenges/04-delivery/solutions/`](../../challenges/04-delivery/solutions/).

> Any app AI capability must use the modular inference provider abstraction (`AI_PROVIDER` in
> `{foundry, azure-openai, github-models}`). Never hard-code a provider or key, and no image
> generation.

## MCP server calls

- `azure`: validate cluster, node pools, identity, ingress/egress, and policy after deployment.
- `github`: confirm GitOps reconciliation and link delivery evidence in the M4 lab issue.
- `microsoft.docs.mcp`: confirm secure-baseline and GitOps deployment guidance.

## Validation / evidence

- [ ] AKS secure baseline deployed with multi-AZ node pools and required add-ons.
- [ ] GitOps trees reconcile and all three apps are running.
- [ ] As-built document saved under the delivery solutions folder.
- [ ] M4 lab issue references B.4.1 and links the evidence.
