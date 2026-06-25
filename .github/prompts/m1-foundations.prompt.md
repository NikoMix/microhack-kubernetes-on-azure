---
mode: agent
description: Drive Module M1 (B.1.1 Certification & K8s foundations) — build a CKA/CKAD readiness map and AKS primer.
tools: ['codebase', 'search', 'fetch']
---

# Module M1 — Certification & Kubernetes Foundations

## Goal

Establish the certification and Kubernetes baseline the engagement team must hold. This module maps
1:1 to Module B control **B.1.1 (Certification & K8s foundations)**.

## Deliverable

- A CKA/CKAD readiness map for the team.
- An AKS / `kubectl` / RBAC primer the trainer can deliver.

## Use the agent and skill

- Drive this lab with the **AKS Engagement Copilot** agent: [`.github/agents/aks-engagement-copilot.agent.md`](../agents/aks-engagement-copilot.agent.md).
- No dedicated Module B skill exists for B.1.1; use the agent plus repo content under
  [`challenges/01-foundations/`](../../challenges/01-foundations/).

## Steps with Copilot

1. Ask Copilot to read [`challenges/01-foundations/README.md`](../../challenges/01-foundations/README.md)
   and extract the required certifications and competencies.
2. Have Copilot build a readiness map matrix (team member vs. CKA/CKAD objective domains) and flag
   gaps.
3. Generate a concise `kubectl` + RBAC primer: cluster access, contexts, namespaces, Roles vs.
   ClusterRoles, and Microsoft Entra ID + Azure RBAC for Kubernetes.
4. Cross-check terminology against current upstream Kubernetes and AKS docs, then refine the primer.
5. Export the readiness map and primer into [`challenges/01-foundations/solutions/`](../../challenges/01-foundations/solutions/).

## MCP server calls

- `microsoft.docs.mcp`: pull current AKS RBAC, Entra integration, and `kubectl` reference material.
- `github`: track readiness-map items as checklist tasks in the M1 lab issue.
- `azure`: optionally inspect an existing AKS cluster's RBAC configuration for a live example.

## Validation / evidence

- [ ] Readiness map lists each team member against CKA/CKAD domains with gap status.
- [ ] Certification evidence (or remediation plan) recorded for B.1.1.
- [ ] AKS/`kubectl`/RBAC primer saved under the foundations solutions folder.
- [ ] M1 lab issue links both artifacts.
