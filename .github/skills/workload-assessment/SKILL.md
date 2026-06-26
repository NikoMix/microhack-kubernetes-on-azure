---
name: workload-assessment
description: >-
  Produce a Module B.2.1 Workload Assessment for a candidate Kubernetes-on-Azure workload: a
  dependency map (inbound/outbound, data stores, identities, external services) plus a
  prioritised, AKS-readiness remediation backlog (12-factor, statefulness, secrets, images,
  observability). Use when assessing an app for migration to AKS, building a dependency map,
  scoring container/AKS readiness, or generating the B.2.1 evidence artifacts.
---

# Workload Assessment (B.2.1)

Turn a candidate workload into two audit-grade artifacts: a **dependency map** and a
**prioritised remediation backlog** that make the workload ready for the AKS secure baseline.
This is the M2 deliverable and satisfies Module B control **B.2.1**.

> Evidence requirements and the per-customer count live in
> [references/evidence-checklist.md](references/evidence-checklist.md). B.2.1 needs **3 unique
> customers, 2 artifacts each**. For greenfield-only Kubernetes use, a **B.3.2 Well-Architected
> Review may substitute** — see the checklist.

## Inputs to gather first

- Source (repo / image / running deployment), language & runtime, build system.
- Inbound callers and protocols; outbound dependencies (APIs, queues, caches, DBs).
- State: in-memory session, local disk, sticky sessions, scheduled jobs.
- Identity & secrets: how it authenticates today; where secrets live.
- Non-functionals: throughput, latency SLOs, data residency, compliance.

Use the **github** MCP server to read the repo and the **azure** MCP server to inspect existing
Azure resources the workload already uses.

## Workflow

1. **Map dependencies.** Fill [assets/dependency-map-template.md](assets/dependency-map-template.md):
   list every inbound/outbound edge, data store, identity, and external service. Render the
   topology as a Mermaid `graph LR` diagram.
2. **Score AKS/container readiness** across these dimensions, RAG-rated with evidence:
   - **Statelessness / 12-factor** — config in env, no local state, graceful shutdown.
   - **Containerisation** — multi-stage distroless/chiseled image, non-root, healthchecks.
   - **Secrets** — externalised to Key Vault + CSI; nothing baked into images.
   - **Identity** — ready for **Microsoft Entra Workload ID** (no static cloud keys).
   - **Networking** — egress endpoints enumerable (for Azure Firewall rules), ingress shape.
   - **Observability** — OpenTelemetry traces/metrics/logs to Azure Monitor (OTLP).
   - **Data** — externalised, backed up, residency-aware.
   - **Resilience** — probes, PDB, replica count, retry/idempotency.
3. **Build the remediation backlog.** For each gap, add a row to
   [assets/remediation-backlog.csv](assets/remediation-backlog.csv) with: item, dimension,
   severity (Blocker/High/Med/Low), effort (S/M/L), target AKS feature, owner, acceptance test.
4. **Prioritise** by `severity × (1/effort)`; Blockers first. Blockers are anything that
   prevents a secure-baseline deploy (in-cluster secrets, root containers, local state).
5. **Tie each item to the design.** Reference the AKS feature that resolves it (Workload ID,
   CSI Secret Store, Container Insights, PDB, App Gateway for Containers, etc.) so the backlog
   feeds directly into the B.3.1 HLD.
6. **Export** anonymised evidence per the naming rule:
   `B2.1_WorkloadAssessment_CustomerA_v1.pdf` and `B2.1_DependencyMap_CustomerA_v1.png`.

## Output

- `dependency-map.md` (+ exported diagram) and `remediation-backlog.csv`, both anonymised.
- A one-paragraph executive summary stating migration verdict (Rehost / Replatform / Refactor)
  and the top 3 blockers.

## Modular AI inference

If the workload includes an AI capability, assess it against the course rule: inference must be
provider-agnostic across **Azure AI Foundry / Azure OpenAI / GitHub Models** (no image gen).
Flag any single-provider lock-in or embedded API key as a **Blocker**. See
[references/modular-inference.md](references/modular-inference.md).

## Learn More

| Topic | How to find |
|---|---|
| AKS migration / readiness | `microsoft_docs_search(query="migrate to AKS readiness checklist")` |
| Workload Identity | `microsoft_docs_search(query="AKS workload identity overview")` |
| Key Vault CSI driver | `microsoft_docs_fetch(url="https://learn.microsoft.com/azure/aks/csi-secrets-store-driver")` |
| App containerisation | `microsoft_code_sample_search(query="dockerfile distroless dotnet", language="dockerfile")` |

### CLI alternative

If the Learn MCP server is unavailable, use the `mslearn` CLI:

| MCP Tool | CLI Command |
|----------|-------------|
| `microsoft_docs_search(query: "...")` | `mslearn search "..."` |
| `microsoft_code_sample_search(query: "...", language: "...")` | `mslearn code-search "..." --language ...` |
| `microsoft_docs_fetch(url: "...")` | `mslearn fetch "..."` |

Run with `npx @microsoft/learn-cli <command>` or install globally via `npm install -g @microsoft/learn-cli`.
