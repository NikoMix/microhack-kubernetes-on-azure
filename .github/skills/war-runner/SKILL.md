---
name: war-runner
description: >-
  Run a Module B.3.2 Azure Well-Architected Review for an AKS workload and export the findings.
  Guides a structured review across the WAF pillars (default Reliability + Security for AKS),
  scores each against the AKS secure baseline, and produces a prioritised improvement backlog.
  Use when conducting a Well-Architected Review, exporting WAF pillar findings, or generating the
  B.3.2 evidence (3 workloads x 2 pillars).
---

# WAR Runner (B.3.2 Well-Architected Review)

Run a structured **Azure Well-Architected Review** against an AKS workload and export the
results as **B.3.2** evidence. Use the HLD from `hld-generator` as the design under review.

> Evidence requirements: [references/evidence-checklist.md](references/evidence-checklist.md).
> B.3.2 needs **3 workloads, ≥2 pillars exported each**. For AKS, default to **Reliability +
> Security**; swap one for **Operational Excellence** when GitOps is the headline.

## Workflow

1. **Set scope.** Name the workload, the two pillars, and the reference architecture.
2. **Walk each pillar** using the AKS-specific question set in
   [references/waf-pillars-aks.md](references/waf-pillars-aks.md). For every check, record the
   current state, a RAG rating, and a concrete recommendation tied to an AKS feature.
3. **Score** each pillar (0–100 or RAG roll-up) and capture the top risks.
4. **Build the improvement backlog.** Prioritise by risk × effort; map each item to an AKS
   feature and (where it touches code/infra) a repo path in `infra/` or `gitops/`.
5. **Mirror the portal review.** If the customer ran the Azure Well-Architected Review tool,
   align findings to its categories so the **exported assessment** is audit-traceable.
6. **Export** anonymised: `B3.2_WellArchitectedReview_CustomerA_Reliability_v1.pdf` (one per
   pillar) using [assets/war-findings-template.md](assets/war-findings-template.md).

## Output

- One findings document per pillar (≥2), each with score, findings table, and backlog.
- A combined top-10 risk register feeding the operate phase (B.5.2 runbooks).

## Modular AI inference

If the workload includes AI, review the inference layer under **Security** (Workload Identity,
no embedded keys) and **Operational Excellence** (provider-agnostic config across Azure AI
Foundry / Azure OpenAI / GitHub Models; no image gen). Single-provider lock-in is a finding.

## Learn More

| Topic | How to find |
|---|---|
| WAF for AKS | `microsoft_docs_fetch(url="https://learn.microsoft.com/azure/well-architected/service-guides/azure-kubernetes-service")` |
| WAR assessment tool | `microsoft_docs_search(query="Azure Well-Architected Review assessment")` |
| Reliability pillar | `microsoft_docs_search(query="well-architected reliability AKS")` |
| Security pillar | `microsoft_docs_search(query="well-architected security containers")` |

### CLI alternative

| MCP Tool | CLI Command |
|----------|-------------|
| `microsoft_docs_search(query: "...")` | `mslearn search "..."` |
| `microsoft_code_sample_search(query: "...", language: "...")` | `mslearn code-search "..." --language ...` |
| `microsoft_docs_fetch(url: "...")` | `mslearn fetch "..."` |

Run with `npx @microsoft/learn-cli <command>` or install globally via `npm install -g @microsoft/learn-cli`.
