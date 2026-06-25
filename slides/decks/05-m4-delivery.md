---
marp: true
theme: microhack
paginate: true
footer: "Kubernetes on Azure - Module B MicroHack"
---

<!-- _class: lead -->
<!-- _paginate: false -->

# M4 · Delivery

## Control B.4.1 · 90 min

Secure baseline, ACR images, Flux GitOps and as-built evidence

<!-- Speaker note: Delivery is where design becomes operational proof. Keep the room focused after lunch. -->

---

# Objectives

- Deploy or inspect the AKS secure baseline
- Push three application images to ACR
- Bootstrap Flux GitOps
- Capture logical, physical and sequence diagrams
- Produce as-built evidence for B.4.1

<!-- Speaker note: Evidence matters as much as the deployment. A working cluster with no as-built is incomplete. -->

---

# Primer refresher

- ACR stores trusted container images
- AKS pulls images using managed identity integration
- Flux reconciles desired state from Git
- As-built documents what actually deployed
- Diagrams explain the build and runtime paths

<!-- Speaker note: Newcomers often mix CI build with GitOps deploy. Separate image publication from cluster reconciliation. -->

---

# Delivery flow

```text
Source -> Build -> ACR -> GitOps manifests -> Flux -> AKS
```

- Build and tag images
- Push to `<acr-login-server>`
- Update GitOps references
- Reconcile Flux
- Verify workloads and observability

<!-- Speaker note: Use placeholders exactly as the lab does. Do not invent resource names. -->

---

# Secure baseline touchpoints

- AKS cluster and node pools
- ACR with managed-identity pull
- Key Vault CSI Secret Store
- Azure Policy and Deployment Safeguards
- Defender for Containers
- Ingress and egress controls
- Container Insights and diagnostics

<!-- Speaker note: The baseline is broader than the app. Walk learners through the platform controls they can verify. -->

---

# Three images to publish

| Service | Runtime |
| --- | --- |
| dotnet-api | .NET 10 Minimal API |
| python-worker | Python 3.14 FastAPI worker |
| node-web | Node 24 Fastify BFF |

- Non-root images
- Health endpoints
- OpenTelemetry enabled

<!-- Speaker note: Do not spend time teaching Docker basics. Focus on evidence that all three workload images reached ACR. -->

---

# Flux GitOps checks

```bash
flux get sources git
flux get kustomizations
kubectl get pods -A
kubectl get events -A
```

- Desired state is in Git
- Reconciliation is observable
- Failures become backlog items

<!-- Speaker note: If Flux commands fail, inspect source, kustomization and workload events in that order. -->

---

# Diagrams required

- Logical: services and dependencies
- Physical: Azure resources and network placement
- Sequence: build, push, reconcile, run
- As-built: deployed values and observed state

<!-- Speaker note: Make diagrams simple and accurate. They support customer handover and B.4.1 evidence. -->

---

# Copilot + MCP

| Item | Used for |
| --- | --- |
| `as-built` skill | Deployment narrative and diagrams |
| Azure MCP | Live resource state |
| GitHub MCP | GitOps repository context |

<!-- Speaker note: Copilot is useful after deployment because it can compare intended design with observed state. -->

---

# Facilitator pitfalls

- Starting deployment before confirming M0 context
- Pushing only one image instead of three
- Flux pointed at the wrong branch or path
- Treating screenshots as as-built documentation
- Missing logical, physical or sequence diagram

<!-- Speaker note: Keep a whiteboard of common errors. Many teams will hit the same image tag or Flux path issue. -->

---

# Validation checklist

- Secure baseline deployed or verified → B.4.1
- Three images present in ACR → B.4.1
- Flux reconciliation successful → B.4.1
- As-built document created → B.4.1
- Logical diagram created → B.4.1
- Physical diagram created → B.4.1
- Sequence diagram created → B.4.1

<!-- Speaker note: B.4.1 requires at least two delivery artifacts plus the named diagrams. Collect the complete set for this MicroHack. -->

---

# Drive it yourself

```text
Invoke the as-built skill after deploying the Module B baseline and app.
Use Azure MCP to inspect AKS, ACR, Key Vault, policy and monitoring.
Use GitHub MCP to inspect Flux GitOps state. Produce as-built notes plus
logical, physical and sequence diagrams for B.4.1.
```

<!-- Speaker note: Ask learners to reconcile the as-built with the HLD. Differences are not failures if they are documented. -->
