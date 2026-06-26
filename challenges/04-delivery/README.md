# M04 · Delivery

Deploy the AKS secure baseline, publish the workshop containers, and let Flux v2 reconcile the application stack from Git.

## Metadata

| Field | Value |
| --- | --- |
| Duration | 90 minutes |
| Control | B.4.1 Delivery |
| Evidence produced | As-built, architecture diagram, logical diagram, physical diagram, sequence diagram, and optionally SOW or project plan |
| You will | Deploy or confirm the AKS baseline, build and push three images to ACR, bootstrap GitOps, verify identity, ingress, and observability, then capture delivery evidence |

## Prerequisites

- M0 is complete: Azure login, subscription context, Kubernetes tooling, Flux CLI, and Copilot MCP connectivity are ready.
- You can deploy to the workshop subscription and can read AKS, ACR, Key Vault, Log Analytics, and GitHub repository settings.
- You are working from the repository root.
- The implementation contracts are available from the source folders: [infra](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/infra), [apps](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/apps), [gitops](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/gitops), and [scripts](https://github.com/NikoMix/microhack-kubernetes-on-azure/tree/main/scripts).
- You have a GitHub repository or branch that Flux can read for the GitOps app-of-apps configuration.

## Primer / concepts

GitOps means the cluster continuously reconciles from Git instead of relying on one-off manual changes. Flux v2 watches a Git source, applies Kustomizations and HelmReleases, and reports drift or failures. In this lab the app-of-apps pattern starts from `gitops/clusters/microhack/`, which points Flux at shared infrastructure and the three application overlays.

Container builds package each service and its runtime into an immutable image. The workshop services use multi-stage Dockerfiles so build tools stay out of the final image, and distroless or chiseled base images so the runtime image is smaller, non-root, and easier to scan. Tags should be unique enough to trace the build, such as a short commit SHA or a dated lab tag.

Managed-identity image pull lets AKS pull from Azure Container Registry without storing registry passwords in Kubernetes secrets. The baseline grants the kubelet or managed identity `AcrPull` on the registry. Workload Identity is separate: pods use annotated service accounts to exchange projected tokens for Microsoft Entra tokens when they call Azure services.

For a refresher, use the AKS primer at [/references/primer/](/references/primer/), the kubectl cheat sheet at [/references/kubectl-cheat-sheet/](/references/kubectl-cheat-sheet/), and the Copilot MCP reference at [/references/copilot-mcp/](/references/copilot-mcp/).

> **Stretch goal for experienced learners:** promote the dev overlay to prod with a pull request, or add a HorizontalPodAutoscaler for `node-web` and record the change in the as-built.

## Copilot + MCP usage

> **Use the AKS Engagement Copilot.** Invoke the `as-built` skill to draft the as-built and diagrams. Use Azure MCP to read deployed resources such as `<cluster-name>`, `<acr-login-server>`, `<oidc-issuer>`, `<key-vault-name>`, and Log Analytics. Use GitHub MCP to inspect the GitOps repository, branch, commits, and Flux source path. If the skill or MCP servers are unavailable, follow the manual templates in `assets/`.

Example prompt:

```text
Invoke the as-built skill for Module B.4.1. Use Azure MCP to read the AKS cluster, ACR, managed identities, Key Vault, ingress, and observability resources. Use GitHub MCP to read the Flux app-of-apps path in gitops/clusters/microhack. Draft an as-built with logical, physical, and sequence diagrams, and list any validation gaps.
```

## Step-by-step instructions

1. Confirm your Azure context and resolve the contract outputs.

   ```bash
   az account show --query "{subscriptionId:id, tenantId:tenantId, user:user.name}" --output table
   az group list --query "[].{name:name, location:location}" --output table
   ```

   Record the values you will use in later commands.

   ```bash
   export SUBSCRIPTION_ID="<subscription-id>"
   export RESOURCE_GROUP="<resource-group>"
   export CLUSTER_NAME="<cluster-name>"
   export ACR_LOGIN_SERVER="<acr-login-server>"
   export ACR_NAME="${ACR_LOGIN_SERVER%%.*}"
   export GITOPS_REPO_URL="https://github.com/<owner>/<repo>.git"
   export GITOPS_BRANCH="main"
   export GITOPS_PATH="gitops/clusters/microhack"
   ```

2. Deploy or confirm the AKS secure baseline through the script contract.

   Use the Bicep track unless your trainer assigns Terraform parity.

   ```bash
   scripts/deploy --track bicep --subscription "$SUBSCRIPTION_ID" --resource-group "$RESOURCE_GROUP" --location westeurope
   ```

   Terraform parity uses the same contract and should produce the same outputs.

   ```bash
   scripts/deploy --track terraform --subscription "$SUBSCRIPTION_ID" --resource-group "$RESOURCE_GROUP" --location westeurope
   ```

   Confirm the cluster and registry outputs. Use Azure MCP if you prefer a read-only resource lookup.

   ```bash
   az aks show --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --query "{name:name, oidcIssuer:oidcIssuerProfile.issuerUrl, workloadIdentity:securityProfile.workloadIdentity.enabled}" --output table
   az acr show --name "$ACR_NAME" --query "{loginServer:loginServer, sku:sku.name}" --output table
   ```

3. Build and push the three polyglot images to ACR.

   Use `az acr build` when you do not have a local Docker daemon. Keep tags consistent across all services.

   ```bash
   export IMAGE_TAG="m4-$(date +%Y%m%d%H%M)"

   az acr build --registry "$ACR_NAME" --image "dotnet-api:$IMAGE_TAG" apps/dotnet-api
   az acr build --registry "$ACR_NAME" --image "python-worker:$IMAGE_TAG" apps/python-worker
   az acr build --registry "$ACR_NAME" --image "node-web:$IMAGE_TAG" apps/node-web
   ```

   If your trainer asks you to build locally, use Docker and push to the same registry.

   ```bash
   az acr login --name "$ACR_NAME"
   docker build --platform linux/amd64 -t "$ACR_LOGIN_SERVER/dotnet-api:$IMAGE_TAG" apps/dotnet-api
   docker build --platform linux/amd64 -t "$ACR_LOGIN_SERVER/python-worker:$IMAGE_TAG" apps/python-worker
   docker build --platform linux/amd64 -t "$ACR_LOGIN_SERVER/node-web:$IMAGE_TAG" apps/node-web
   docker push "$ACR_LOGIN_SERVER/dotnet-api:$IMAGE_TAG"
   docker push "$ACR_LOGIN_SERVER/python-worker:$IMAGE_TAG"
   docker push "$ACR_LOGIN_SERVER/node-web:$IMAGE_TAG"
   ```

4. Connect kubectl and bootstrap Flux v2 app-of-apps.

   ```bash
   az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --overwrite-existing
   scripts/bootstrap-gitops --cluster "$CLUSTER_NAME" --resource-group "$RESOURCE_GROUP" --repo "$GITOPS_REPO_URL" --branch "$GITOPS_BRANCH" --path "$GITOPS_PATH"
   ```

   Confirm Flux can see the Git source and Kustomizations.

   ```bash
   flux get sources git -A
   flux get kustomizations -A
   ```

5. Watch reconciliation and workload health.

   ```bash
   flux reconcile source git flux-system --namespace flux-system
   flux get kustomizations -A --watch
   kubectl get pods -A
   kubectl get deploy,svc,ingress -A
   ```

   The application namespaces should show Running pods for `dotnet-api`, `python-worker`, and `node-web`.

6. Verify Workload Identity, managed-identity image pull, ingress, and observability.

   ```bash
   kubectl get serviceaccount -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{" => "}{.metadata.annotations.azure\.workload\.identity/client-id}{"\n"}{end}'
   kubectl describe pod -n apps -l app.kubernetes.io/name=node-web | grep -E "Image:|Service Account:|Pulled|Started"
   kubectl get ingress -A
   kubectl get pods -n ama-metrics
   kubectl get pods -n kube-system -l rsName=ama-logs
   ```

   Use the ingress host or external address to test the web front door.

   ```bash
   curl --fail --show-error --location "https://<ingress-host>/health"
   ```

   In Azure Portal or Azure MCP, confirm Container Insights or Log Analytics has recent container inventory and application telemetry.

7. Capture the as-built and diagrams.

   Start from the templates in `assets/as-built-template.md`, `assets/diagrams.md`, and `assets/project-plan-template.md`. Use the `as-built` Copilot skill where available, then validate every generated resource name against Azure MCP or `az` output.

   ```bash
   az aks show --resource-group "$RESOURCE_GROUP" --name "$CLUSTER_NAME" --output json
   az acr repository list --name "$ACR_NAME" --output table
   az monitor log-analytics workspace list --resource-group "$RESOURCE_GROUP" --output table
   ```

## Validation checklist

- [ ] As-built document completed with environment, deployed resources, identities, network, ingress, images, GitOps, observability, and validation notes. → B.4.1: as-built
- [ ] Architecture diagram produced and attached to the evidence pack. → B.4.1: architecture diagram
- [ ] Logical, physical, and sequence diagrams are present and match the deployed state. → B.4.1: required diagrams
- [ ] At least two delivery artifacts are ready for scoring, with as-built and architecture diagram as the minimum set. → B.4.1: evidence set
- [ ] `dotnet-api`, `python-worker`, and `node-web` images exist in ACR with the lab tag. → B.4.1: delivery evidence
- [ ] Flux source and Kustomizations are Ready. → B.4.1: GitOps delivery
- [ ] Workloads are Running and use Workload Identity service accounts where required. → B.4.1: implementation evidence
- [ ] Ingress responds successfully from the test client. → B.4.1: implementation evidence
- [ ] Container Insights or Azure Monitor shows recent telemetry. → B.4.1: observability evidence

## Success criteria

You have a deployed AKS baseline, three application images in ACR, Flux reconciling the app-of-apps path, application pods Running, ingress reachable, Workload Identity configured, and observability flowing into Azure Monitor.

## What you produced

- A completed as-built.
- An architecture diagram plus logical, physical, and sequence diagrams.
- Build and deployment evidence for the three service images.
- Flux and Kubernetes validation output.
- Optional SOW or project plan evidence if your trainer asks for more than the minimum set.

## Clean-up note

Do not tear down the environment at the end of this module. M5 and M6 reuse the deployment. Defer teardown until the end of the day or until the trainer asks you to run `scripts/teardown`.

## Next module

Continue to [M05 · Validate](../05-validate/).
