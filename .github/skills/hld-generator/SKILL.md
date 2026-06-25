---
name: hld-generator
description: >-
  Generate a Module B.3.1 Solution Design — a High-Level Design (HLD) for an AKS landing zone /
  secure baseline that covers EVERY required design area (identity & RBAC, network topology,
  cluster & node pools, namespaces & tenancy, workload scheduling & resilience, security &
  compliance, secrets, storage & data, observability, governance & cost, business continuity /
  DR, CI/CD & GitOps, container registry & supply chain, platform currency). Use when producing
  an AKS HLD, solution design document, or architecture deliverable for B.3.1.
---

# HLD Generator (B.3.1 Solution Design)

Produce an audit-grade **AKS landing-zone High-Level Design** that addresses **every** design
area an auditor expects for **B.3.1**. The design targets the **AKS secure baseline** in
`infra/bicep/` (AVM-first) with a Terraform parity track in `infra/terraform/`.

> Evidence requirements: [references/evidence-checklist.md](references/evidence-checklist.md).
> B.3.1 needs **3 unique customers, 2 artifacts each**, and the design must address **all** AKS
> design areas — a missing area fails the control.

## Inputs to gather first

- The **B.2.1 workload assessment** output (dependency map + remediation backlog) — every
  remediation item must map to a design decision here.
- Customer constraints: region(s) (default `westeurope`), compliance regime, connectivity
  (greenfield vs. hub/spoke ALZ), private vs. public, scale and SLO targets, budget.
- Existing platform: landing zones, hub network, Entra tenant, policy baseline.

Ground each decision in current docs via the **microsoft.docs.mcp** server; inspect the target
subscription with the **azure** MCP server.

## Workflow

1. **Pick the reference architecture** (see [references/design-areas.md](references/design-areas.md)
   for the routing table): first prod / single region → AKS baseline; regulated / private →
   **AKS secure baseline**; multi-region → add Front Door + App Gateway for Containers;
   enterprise ALZ → AKS landing-zone accelerator.
2. **Fill the HLD template** [assets/hld-template.md](assets/hld-template.md). It has **one
   section per design area** — do not delete sections; mark `N/A` with a reason if truly out of
   scope. Each area states: decision, rationale, AVM module / AKS feature, and the alternative
   considered.
3. **Decisions register.** Capture each significant choice as an ADR-style row (decision,
   options, choice, rationale, consequences) in the template's register.
4. **Draw the architecture** as a Mermaid diagram (cluster, node pools, networking, ingress/
   egress, registry, identity, observability) and export it as an evidence artifact.
5. **Trace requirements.** Add a traceability table mapping each B.2.1 remediation item and each
   non-functional requirement to the design area that satisfies it.
6. **Hand off to B.3.2.** The HLD is the input to the `war-runner` skill — list the two WAF
   pillars you will review (default Reliability + Security).
7. **Export** anonymised: `B3.1_SolutionDesign_CustomerA_v1.pdf` +
   `B3.1_ArchitectureDiagram_CustomerA_v1.png`.

## Design areas (all mandatory — full detail in references/design-areas.md)

Identity & access · Network topology & connectivity · Cluster & node pools · Namespaces &
tenancy · Workload scheduling & resilience · Security & compliance · Secrets management ·
Storage & data · Observability & monitoring · Governance & cost · Business continuity / DR ·
CI/CD & GitOps · Container registry & supply chain · Platform lifecycle & currency.

## Modular AI inference

If the design includes an AI capability (e.g. an inference endpoint or agent), document the
**provider-agnostic** inference layer (Azure AI Foundry / Azure OpenAI / GitHub Models, no image
gen) as part of the Security and Application design areas. See
[references/modular-inference.md](references/modular-inference.md).

## Learn More

| Topic | How to find |
|---|---|
| AKS baseline reference | `microsoft_docs_fetch(url="https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks/baseline-aks")` |
| AKS landing zone accelerator | `microsoft_docs_search(query="AKS landing zone accelerator design areas")` |
| AVM AKS module | `microsoft_docs_search(query="Azure Verified Modules AKS managed cluster")` |
| CNI Overlay | `microsoft_docs_search(query="Azure CNI Overlay AKS networking")` |

### CLI alternative

| MCP Tool | CLI Command |
|----------|-------------|
| `microsoft_docs_search(query: "...")` | `mslearn search "..."` |
| `microsoft_code_sample_search(query: "...", language: "...")` | `mslearn code-search "..." --language ...` |
| `microsoft_docs_fetch(url: "...")` | `mslearn fetch "..."` |

Run with `npx @microsoft/learn-cli <command>` or install globally via `npm install -g @microsoft/learn-cli`.
