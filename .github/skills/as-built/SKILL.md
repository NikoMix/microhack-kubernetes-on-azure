---
name: as-built
description: >-
  Generate a Module B.4.1 / B.5.2 as-built document capturing the actually-deployed AKS secure
  baseline and migrated workloads: resources, versions, network, identity, GitOps state, and
  deltas from the B.3.1 HLD. Use when documenting a delivered AKS environment, producing an
  as-built / delivery artifact, or generating B.4.1 delivery evidence and the B.5.2 ops record.
---

# As-Built (B.4.1 Delivery / B.5.2 Documentation)

Capture the **actually-deployed** AKS secure baseline and migrated polyglot workloads as an
audit-grade as-built. It is a primary **B.4.1** delivery artifact and part of the **B.5.2** ops
record (M4/M6).

> Evidence requirements: [references/evidence-checklist.md](references/evidence-checklist.md).
> B.4.1 needs **3 customers** with **≥2 of**: SOW, design doc, project plan, architecture
> diagrams, **as-built**.

## Workflow

1. **Discover the deployed state** with the **azure** MCP server and `kubectl`/`az`: cluster
   config (K8s version, node pools, AZs, CNI), networking (VNet/subnets, private cluster,
   firewall, ingress), identity (Entra integration, Workload Identity), ACR, Key Vault, Defender,
   Azure Policy, Monitor/Prometheus/Grafana.
2. **Record versions** of everything (K8s, node image, add-ons, AVM modules, app images, charts)
   for the platform-currency baseline.
3. **Capture GitOps state** from `gitops/` (Flux Kustomizations/HelmReleases, source revision)
   and the deployed app overlays.
4. **Diagram the as-built** (Mermaid) and export it.
5. **Delta vs. HLD.** Compare to the B.3.1 design; record every deviation with a reason and an
   owner (deviations with customer acknowledgement are acceptable audit evidence).
6. **Fill** [assets/as-built-template.md](assets/as-built-template.md) and **export** anonymised:
   `B4.1_AsBuilt_CustomerA_v1.pdf` + `B4.1_ArchitectureDiagram_CustomerA_v1.png`.

## Output

- As-built document, exported diagram, version inventory, and an HLD-delta table.

## Modular AI inference

If an AI capability is deployed, document the provider-agnostic inference layer (Azure AI
Foundry / Azure OpenAI / GitHub Models, no image gen), how the provider is selected, and that
credentials come from Key Vault / Workload Identity. See
[references/modular-inference.md](references/modular-inference.md).

## Learn More

| Topic | How to find |
|---|---|
| AKS cluster configuration | `microsoft_docs_search(query="az aks show cluster configuration")` |
| GitOps Flux on AKS | `microsoft_docs_fetch(url="https://learn.microsoft.com/azure/azure-arc/kubernetes/conceptual-gitops-flux2")` |
| AVM modules | `microsoft_docs_search(query="Azure Verified Modules bicep registry")` |
| Workload Identity verify | `microsoft_docs_search(query="verify AKS workload identity federated credential")` |

### CLI alternative

| MCP Tool | CLI Command |
|----------|-------------|
| `microsoft_docs_search(query: "...")` | `mslearn search "..."` |
| `microsoft_code_sample_search(query: "...", language: "...")` | `mslearn code-search "..." --language ...` |
| `microsoft_docs_fetch(url: "...")` | `mslearn fetch "..."` |

Run with `npx @microsoft/learn-cli <command>` or install globally via `npm install -g @microsoft/learn-cli`.
