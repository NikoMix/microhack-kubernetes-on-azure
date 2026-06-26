# SOW excerpt example

This trainer-only SOW excerpt is an optional B.4.1 delivery artifact. It is intentionally concise so learners can compare scope language with the as-built.

## Engagement summary

Contoso will deploy the approved AKS secure baseline in West Europe, publish three workshop application images to Azure Container Registry, and configure Flux v2 to reconcile the application platform from the GitOps repository. The delivery outcome is a running AKS workload stack with managed-identity image pull, Workload Identity, ingress, and Container Insights telemetry.

## In scope

- Deploy the AKS secure baseline using the approved Bicep track, with Terraform parity available if requested.
- Configure AKS, ACR, Key Vault, ingress, Azure Policy, Defender for Containers, Container Insights, Managed Prometheus, and Grafana according to the workshop baseline.
- Build and publish `dotnet-api`, `python-worker`, and `node-web` images with traceable tags.
- Bootstrap Flux v2 against `gitops/clusters/microhack` on the `main` branch.
- Validate Flux Ready state, Running workloads, ingress response, Workload Identity configuration, and telemetry flow.
- Produce an as-built and architecture diagram package with logical, physical, and sequence diagrams.

## Out of scope

- Production cutover, data migration, and customer DNS delegation beyond the workshop ingress host.
- Long-running load testing, resilience testing, and customer sign-off, which are handled in Module M5.
- Day-2 operating model, SLOs, and platform currency, which are handled in Module M6.

## Deliverables

| Deliverable | Acceptance criteria |
| --- | --- |
| AKS baseline deployment | Baseline resources exist in the target subscription and region |
| Container images | Three tagged images are present in the approved ACR |
| GitOps bootstrap | Flux source and Kustomizations are Ready |
| Runtime validation | Pods are Running and ingress health endpoint returns success |
| Identity validation | Managed-identity image pull and Workload Identity are evidenced |
| Observability validation | Container Insights or Azure Monitor shows recent telemetry |
| Delivery evidence pack | As-built, architecture diagram, logical diagram, physical diagram, and sequence diagram are complete |

## Assumptions

- The subscription has quota in West Europe and permissions for AKS, ACR, Key Vault, monitoring, and networking resources.
- The GitOps repository is reachable from Flux and has the required branch and path.
- Learners use approved scripts and do not hard-code resource names outside the documented contract outputs.
