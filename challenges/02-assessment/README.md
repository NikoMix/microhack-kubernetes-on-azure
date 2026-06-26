# M2 · Workload assessment and dependency mapping

Assess the polyglot AKS workload, map its dependencies, and prioritise remediation before migration.

## Metadata

| Item | Value |
| --- | --- |
| Duration | 60 minutes |
| Control | B.2.1 · Workload Assessment |
| Evidence produced | Dependency map; prioritised remediation backlog with effort and risk |
| You will | Inventory three services, trace dependencies, classify network/state/secrets, and produce migration-readiness evidence |

## Prerequisites

- M0 is complete: Azure access, AKS tooling, repository access, and Copilot/MCP connectivity are validated.
- You can inspect the deployed AKS environment through Azure MCP or Azure CLI with reader access to `<subscription-id>` and `<resource-group>`.
- You can view the app contracts in the source folders:
  - [dotnet-api](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/apps/dotnet-api)
  - [python-worker](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/apps/python-worker)
  - [node-web](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/apps/node-web)
- Keep `/references/primer/` and `/references/copilot-mcp/` open for AKS and Copilot/MCP reminders.

## Primer / concepts

A workload assessment is the structured discovery of what an application is, how it runs, what it depends on, and what would block a safe migration or production rollout. In Azure Migrate terms, you move through discovery, dependency analysis, and readiness planning: first collect facts, then understand runtime relationships, then convert gaps into a prioritised backlog.

Dependency mapping matters because Kubernetes failures often come from relationships that are not visible in source code alone. A service can look healthy while it cannot resolve DNS, pull from ACR, read Key Vault secrets, reach a queue, or export telemetry. Your map should capture five categories:

- Upstream and downstream services: callers, callees, shared platform services, and external systems.
- Data flows: request paths, asynchronous messages, telemetry, and configuration reads.
- Network: ports, protocols, ingress, egress, DNS, firewall, and network policy expectations.
- State and persistence: queues, databases, durable files, caches, and whether a component is stateless.
- Secrets and identity: Key Vault CSI, managed identity, Entra Workload Identity, registry pull identity, and secret rotation expectations.

Experienced learners can use the stretch goal to add a network policy gap analysis after the core evidence is complete.

## Copilot + MCP usage

> Invoke the `workload-assessment` skill via the AKS Engagement Copilot. If the skill is unavailable, follow the manual steps below and use the templates in `assets/`.
>
> Example prompt: `Use the workload-assessment skill for Module B M2. Assess node-web, dotnet-api, and python-worker on AKS. Use Microsoft Docs MCP for Azure Migrate and AKS guidance, then use Azure MCP to inspect AKS, ACR, Key Vault, Azure Monitor, workload identity, service ports, probes, and network dependencies. Produce a dependency map and a risk/effort remediation backlog for B.2.1.`

Use Microsoft Docs MCP to ground Azure Migrate discovery, dependency analysis, AKS workload identity, Key Vault CSI, probes, resource requests/limits, network policy, Azure Monitor, and Defender for Containers guidance. Use Azure MCP to inspect live resource configuration such as AKS services, identities, Key Vault, ACR, Container Insights, and policy add-ons.

## Step-by-step instructions

1. Create your working copies of the evidence templates.

   ```bash
   mkdir -p evidence/m2-assessment
   cp challenges/02-assessment/assets/dependency-map-template.md evidence/m2-assessment/dependency-map.md
   cp challenges/02-assessment/assets/remediation-backlog-template.csv evidence/m2-assessment/remediation-backlog.csv
   cp challenges/02-assessment/assets/assessment-questionnaire.md evidence/m2-assessment/assessment-questionnaire.md
   ```

2. Inventory the three services and record runtimes, ports, and health endpoints.

   ```bash
   kubectl get deploy,svc,pod -A -l app.kubernetes.io/part-of=microhack -o wide
   kubectl describe deploy -A -l app.kubernetes.io/part-of=microhack
   kubectl get endpoints -A
   ```

   Capture the expected service facts in your dependency map:

   | Service | Runtime | Role | Expected endpoint evidence |
   | --- | --- | --- | --- |
   | `node-web` | Node 24 Fastify | Web BFF and front door | Status page, service port, readiness/liveness probes |
   | `dotnet-api` | .NET 10 ASP.NET Core Minimal API | Orders REST API | `/health`, OpenAPI, service port |
   | `python-worker` | Python 3.14 FastAPI async worker | Queue consumer and metrics producer | Metrics endpoint, consumer configuration, probes |

3. Trace the dependency chain and record each edge.

   ```bash
   kubectl get svc -A
   kubectl get configmap,secret,serviceaccount -A
   kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}{"\t"}{.spec.serviceAccountName}{"\t"}{range .spec.containers[*].env[*]}{.name}{"="}{.value}{";"}{end}{"\n"}{end}'
   ```

   Map these expected relationships: `node-web` calls `dotnet-api`; `dotnet-api` writes orders and publishes queue messages; `python-worker` consumes the queue; all services pull images from ACR, read secrets through Key Vault CSI, and emit OpenTelemetry to Azure Monitor.

4. Resolve platform values through Azure MCP or Azure CLI instead of hard-coding names.

   ```bash
   az aks show --resource-group <resource-group> --name <cluster-name> --query '{name:name, oidc:oidcIssuerProfile.issuerUrl, network:networkProfile.networkPlugin}' --output table
   az acr show --name <acr-name> --query '{loginServer:loginServer, sku:sku.name}' --output table
   az keyvault show --name <key-vault-name> --query '{name:name, tenant:properties.tenantId, purgeProtection:properties.enablePurgeProtection}' --output table
   ```

   If Azure MCP is available, ask it to inspect the same resources and paste the relevant findings into the evidence file.

5. Classify network, state, and secrets for each service.

   ```bash
   kubectl get ingress,httproute,networkpolicy -A
   kubectl get serviceaccount -A -o yaml
   kubectl get pods -A -o jsonpath='{range .items[*]}{.metadata.namespace}/{.metadata.name}{"\t"}{range .spec.volumes[*]}{.csi.driver}{":"}{.csi.volumeAttributes.secretProviderClass}{";"}{end}{"\n"}{end}'
   ```

   Record ports, ingress paths, egress destinations, durable state, configuration sources, identities, and whether secrets are mounted through Key Vault CSI rather than environment variables.

6. Build the dependency map.

   Fill `evidence/m2-assessment/dependency-map.md` with a Mermaid diagram and the five category tables. Keep the diagram focused on this lab scope so it remains readable.

7. Generate the remediation backlog.

   Start from `evidence/m2-assessment/remediation-backlog.csv` and add findings such as non-root/distroless verification, resource requests and limits, readiness/liveness probes, Key Vault CSI usage, image scanning, workload identity, network policy, telemetry, and state backup expectations.

8. Prioritise by risk and effort.

   Use this simple rule: high risk and low effort becomes `P0`; high risk and medium/high effort becomes `P1`; medium risk items become `P2`; low risk items become `P3`. Add an owner and status for every row.

9. Stretch goal: add a network policy gap analysis.

   ```bash
   kubectl get networkpolicy -A -o yaml
   kubectl get pods -A --show-labels
   ```

   Compare observed policies with the required flows: ingress to `node-web`, `node-web` to `dotnet-api`, `dotnet-api` to queue/database, `python-worker` to queue, and all services to DNS, Key Vault, ACR, and Azure Monitor endpoints.

## Validation checklist

- [ ] Dependency map includes upstream/downstream services, data flows, network, state, and secrets → B.2.1: dependency map.
- [ ] Dependency map shows `node-web`, `dotnet-api`, `python-worker`, ACR, Key Vault, Azure Monitor, queue, data store, and Entra Workload Identity → B.2.1: dependency map.
- [ ] Remediation backlog is prioritised and includes risk, effort, remediation, owner, and status → B.2.1: remediation backlog.
- [ ] Backlog items are evidence-based and tied to migration readiness, security, reliability, or operational gaps → B.2.1: remediation backlog.

## Success criteria

You can explain the workload topology, identify what must be ready before migration or production rollout, and defend the priority order of your backlog.

## What you produced

- `evidence/m2-assessment/dependency-map.md`
- `evidence/m2-assessment/remediation-backlog.csv`
- Optional completed `evidence/m2-assessment/assessment-questionnaire.md`

## Clean-up note

Do not tear down shared resources after this lab. End-of-day clean-up is handled by `scripts/teardown` when the trainer instructs the class.

## Next module

Continue to [M3 · Solution design](/modules/m3-design/).
