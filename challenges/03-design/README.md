# M03 · Solution design and Well-Architected Review

Create the high-level design, architecture diagram, and Well-Architected Review evidence for an AKS secure-baseline landing zone.

## Metadata

| Item | Value |
| --- | --- |
| Duration | 90 minutes, starting at 11:15 |
| Control | B.3.1 Solution Design and B.3.2 Well-Architected Review |
| Evidence produced | Design document, architecture diagram, WAR export for Reliability and Security, pillar rationale, prioritised backlog |
| You will | Turn the M2 assessment into an AKS high-level design, diagram the landing zone, review it against Azure Well-Architected Framework pillars, and export trainer-scored evidence |

## Prerequisites

- M0 completed: Azure access, tools, Copilot agent connection, and MCP reachability confirmed.
- M2 completed: dependency map, remediation backlog, requirements, constraints, risks, and known workload assumptions.
- Access to the AKS Engagement Copilot, or the manual templates in this folder if the agent or skills are unavailable.
- Reader access to the deployed environment so Azure MCP can inspect `<subscription-id>`, `<resource-group>`, `<cluster-name>`, `<acr-login-server>`, `<oidc-issuer>`, `<key-vault-name>`, and the Log Analytics workspace.
- Familiarity with the secure-baseline contract in the `infra/` workspace, which deploys AKS in `westeurope` using Bicep and Terraform Azure Verified Modules.

## Primer and concepts

An HLD, or high-level design, explains the target solution before implementation. It records the main decisions, trade-offs, dependencies, risks, and responsibilities so the customer, delivery team, and operations team share the same mental model.

A landing zone is the prepared Azure foundation for a workload. In this lab, the landing zone is a hub-and-spoke AKS secure baseline: the hub centralises shared services such as Azure Firewall, DNS, and connectivity; the spoke hosts AKS, Azure Container Registry, Key Vault, monitoring, and workload ingress.

The AKS secure-baseline reference architecture combines private networking, Microsoft Entra ID, Azure RBAC, Workload Identity, Azure Policy for AKS, Defender for Containers, Container Insights, Managed Prometheus, Grafana, Key Vault CSI Secret Store, and controlled ingress and egress. Start with Microsoft guidance at [AKS baseline architecture](https://learn.microsoft.com/azure/architecture/reference-architectures/containers/aks/baseline-aks) and [Well-Architected Framework service guide for AKS](https://learn.microsoft.com/azure/well-architected/service-guides/azure-kubernetes-service).

A Well-Architected Review matters because it turns design quality into explicit findings. For this module, you review Reliability and Security, explain the rationale for each pillar score, and create a prioritised backlog that can feed M4 delivery and M5 validation.

Stretch goal for experienced learners: add a private-cluster variant that uses App Gateway for Containers, private endpoints where appropriate, Azure Firewall egress, custom DNS forwarding, and stricter admission controls.

## Copilot and MCP usage

> Invoke the `hld-generator` skill, then the `war-runner` skill, through the AKS Engagement Copilot. Use Microsoft Docs MCP for AKS baseline and Well-Architected guidance. Use Azure MCP to read the deployed environment. If the skills are unavailable, follow the manual steps and templates below.

Copy or adapt this prompt:

```text
Use the hld-generator skill for Module B M3. Read the M2 assessment, the infra secure-baseline contract, the apps polyglot workload contract, and the deployed Azure environment through Azure MCP. Produce an HLD that covers all 14 required B.3.1 design areas, plus a landing-zone architecture diagram, cluster design document, and network design document. Then use war-runner for Reliability and Security only, include pillar rationale, severity, and a prioritised backlog.
```

## Step-by-step instructions

1. Gather design inputs.

   - Open your M2 dependency map and remediation backlog.
   - Confirm workload assumptions for `dotnet-api`, `python-worker`, and `node-web`.
   - Resolve deployed values with Azure MCP or Azure CLI. Use placeholders if the environment is not deployed yet.

   ```bash
   az aks show --resource-group <resource-group> --name <cluster-name> --query "{name:name, location:location, oidcIssuer:oidcIssuerProfile.issuerUrl, networkPlugin:networkProfile.networkPlugin, networkPluginMode:networkProfile.networkPluginMode}" --output table
   az acr show --name <acr-name> --query "{loginServer:loginServer, sku:sku}" --output table
   az monitor log-analytics workspace show --resource-group <resource-group> --workspace-name <workspace-name> --query "{name:name, location:location}" --output table
   ```

2. Generate the HLD section by section.

   - Start from [`assets/hld-template.md`](assets/hld-template.md).
   - Cover every required B.3.1 design area without merging or skipping sections.
   - Reference the `infra/` contract for the AKS secure baseline and the `apps/` contract for workload requirements.
   - Use Microsoft Docs MCP to confirm current AKS guidance before finalising decisions.

   Required design areas:

   1. IAM/RBAC with Microsoft Entra ID.
   2. Network architecture.
   3. Security.
   4. Governance and cost.
   5. Backup and business continuity.
   6. Regulatory compliance.
   7. Cluster RBAC.
   8. Continuous image vulnerability scanning.
   9. Resource requests, limits, namespaces, ResourceQuotas, and LimitRanges.
   10. Monitoring and alerting.
   11. Liveness, readiness, and startup probes.
   12. Secrets in Key Vault.
   13. Cluster design document.
   14. Network design document.

3. Produce the architecture and supporting design documents.

   - Adapt [`assets/architecture-diagram.md`](assets/architecture-diagram.md) into your evidence folder.
   - Complete [`assets/cluster-design-doc-template.md`](assets/cluster-design-doc-template.md).
   - Complete [`assets/network-design-doc-template.md`](assets/network-design-doc-template.md).
   - Keep the diagram at landing-zone level: hub, spoke, AKS, ACR, Key Vault, Firewall, ingress, Entra, Monitor, and operational flows.

4. Run the Well-Architected Review for Reliability and Security.

   - Invoke `war-runner` through the AKS Engagement Copilot, or manually review against [Azure Well-Architected Framework](https://learn.microsoft.com/azure/well-architected/).
   - Scope the review to Reliability and Security only.
   - Capture each finding with severity, evidence, and a concrete recommendation.
   - Explain the rationale for each pillar rating so the backlog is defensible.

5. Export the WAR evidence and prioritised backlog.

   - Use [`assets/war-backlog-template.csv`](assets/war-backlog-template.csv).
   - Sort by Priority, then Severity, then implementation dependency.
   - Include findings that are design work, delivery work, and validation work so later modules can consume the backlog.

## Validation checklist

- [ ] The design document covers all 14 required design areas. → B.3.1: design document.
- [ ] The architecture diagram is present and shows landing-zone relationships and traffic paths. → B.3.1: architecture diagram.
- [ ] The cluster design document records node pools, sizing, availability zones, upgrades, identity, and operations choices. → B.3.1: design document.
- [ ] The network design document records address spaces, subnets, peering, firewall rules, ingress, egress, and DNS. → B.3.1: design document.
- [ ] The WAR export covers Reliability and Security only. → B.3.2: WAR export.
- [ ] Each WAR pillar includes rationale. → B.3.2: pillar rationale.
- [ ] The backlog is prioritised and has owner, effort, severity, and status. → B.3.2: prioritised backlog.

## Success criteria

You can explain why each AKS design decision supports the customer requirements, how the landing zone protects and observes the workload, and which Reliability and Security improvements are most urgent.

## What you produced

- A completed HLD.
- A landing-zone architecture diagram.
- A completed cluster design document.
- A completed network design document.
- A WAR export for Reliability and Security.
- A prioritised backlog.

## Clean-up note

Do not tear down resources during this lab. Defer cleanup until the end of the day and use `scripts/teardown` when instructed.

## Next module

Continue to [M4 Delivery](/modules/m4-delivery/).
