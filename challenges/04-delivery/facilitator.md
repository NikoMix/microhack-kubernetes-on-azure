# M04 facilitator guide · Delivery

Use this guide to run the 90-minute delivery lab for Control B.4.1 and collect scoreable evidence.

## Timing breakdown

| Time | Activity | Facilitation focus |
| --- | --- | --- |
| 0-10 min | Re-anchor after lunch and explain GitOps delivery | Reconnect M3 design choices to the deployable baseline |
| 10-25 min | Deploy or confirm AKS baseline | Keep one projected terminal on the Bicep track; explain Terraform parity only if used |
| 25-45 min | Build and push three images | Emphasize image tags, ACR login server resolution, and non-root multi-stage builds |
| 45-60 min | Bootstrap Flux v2 app-of-apps | Show how a Git source leads to Kustomizations, HelmReleases, and apps |
| 60-75 min | Verify workloads, identity, ingress, and telemetry | Drive evidence capture while learners run commands |
| 75-85 min | Draft as-built and diagrams | Let Copilot accelerate, then require learners to verify every value |
| 85-90 min | Evidence handoff and scoring reminder | Confirm artifacts align to B.4.1 and link the next validation module |

## Talking points

- Delivery evidence is not just a running cluster; it is a traceable package showing what was deployed, how it was deployed, and how the deployed state was verified.
- GitOps makes Git the intended state. Flux reconciles from Git and surfaces drift, auth, image, and dependency problems quickly.
- The AKS baseline separates platform identity from workload identity. Managed-identity image pull handles ACR access; Workload Identity handles pod-to-Azure access.
- Image tags are part of the delivery contract. Avoid `latest` because it breaks evidence traceability.
- The as-built should be factual and current. Copilot can draft it, but Azure MCP or `az` output is the source of truth for deployed resources.

## Common pitfalls and fixes

| Pitfall | Symptom | Fix |
| --- | --- | --- |
| ACR pull auth missing | Pods show `ImagePullBackOff` or `ErrImagePull` | Confirm AKS kubelet identity has `AcrPull` on the ACR scope; avoid registry passwords in Kubernetes secrets |
| Wrong image platform or architecture | Pods crash immediately or cannot start on the node pool | Build for `linux/amd64` unless the trainer confirms an ARM64 node pool |
| Image tag mismatch | Flux applies manifests but pods pull an old or missing image | Use one `IMAGE_TAG` for all services and update the GitOps overlay before reconciling |
| Flux source not reconciling | `flux get sources git -A` shows not Ready | Check repository URL, branch, path, deploy key, and network egress through the firewall |
| Kustomization dependency failure | One Kustomization waits or fails while others are Ready | Inspect `flux describe kustomization <name> -n <namespace>` and apply dependencies in order |
| Ingress DNS or certificate not ready | Service works internally but browser fails | Check ingress address, DNS record, certificate issuer, and App Gateway for Containers or managed NGINX status |
| Workload Identity missing annotation | Pod starts but Azure calls fail with auth errors | Verify service account annotation `azure.workload.identity/client-id` and federated credential subject |
| Telemetry absent | Container Insights dashboards are empty | Confirm AMA pods are Running, diagnostic settings exist, and the workspace is the expected one |

## Demo-vs-drive guidance

Demo the first baseline confirmation and one `az acr build` command so newer learners see the full pattern. Then let learners drive the remaining image builds and Flux verification. Demo GitHub MCP and Azure MCP reads only if the cohort is new to MCP. Let experienced learners drive Copilot as-built generation and compare it with manual `az` output.

If the lab environment is slow, use one shared trainer deployment for the baseline and have learner pairs complete image, GitOps, validation, and evidence capture against assigned namespaces or overlays.

## Cohort-split tips

- Newer learners: pair them with a driver who reads commands aloud, pauses after each verification command, and maps output to the evidence checklist.
- Experienced learners: assign stretch goals such as dev-to-prod overlay promotion, HPA addition, image tag automation, or a targeted Flux failure diagnosis.
- Mixed tables: keep the newer learner as evidence owner and the experienced learner as command driver so both roles stay active.

## Evidence collected

Collect the following items for scoring with the trainer rubric in [scoring.md](../../trainer-guide/scoring.md):

- As-built with environment, resources, identities, network, ingress, images, GitOps, observability, and validation sections.
- Architecture diagram plus logical, physical, and sequence diagrams.
- At least one additional delivery artifact when available, such as SOW excerpt, design excerpt, or project plan.
- Command output or screenshots showing ACR images, Flux Ready state, Running pods, ingress response, and Container Insights telemetry.
- Notes on any deviations from the baseline contract and how learners resolved them.
