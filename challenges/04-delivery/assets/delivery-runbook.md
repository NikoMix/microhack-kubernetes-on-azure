# Delivery runbook

This runbook gives the ordered delivery steps for the AKS secure baseline, ACR images, Flux v2 bootstrap, and verification.

## Inputs to resolve

| Placeholder | How to resolve |
| --- | --- |
| `<subscription-id>` | `az account show --query id -o tsv` or Azure MCP subscription lookup |
| `<resource-group>` | Trainer-provided resource group or Azure MCP resource group lookup |
| `<cluster-name>` | `az aks list -g <resource-group> --query "[].name" -o tsv` |
| `<acr-login-server>` | `az acr list -g <resource-group> --query "[0].loginServer" -o tsv` |
| `<oidc-issuer>` | `az aks show -g <resource-group> -n <cluster-name> --query oidcIssuerProfile.issuerUrl -o tsv` |
| `<key-vault-name>` | `az keyvault list -g <resource-group> --query "[].name" -o tsv` |

## Baseline deployment · Bicep track

1. Set the common variables.

   ```bash
   export SUBSCRIPTION_ID="<subscription-id>"
   export RESOURCE_GROUP="<resource-group>"
   export LOCATION="westeurope"
   ```

2. Run the script contract for the primary Bicep implementation.

   ```bash
   scripts/deploy --track bicep --subscription "$SUBSCRIPTION_ID" --resource-group "$RESOURCE_GROUP" --location "$LOCATION"
   ```

3. Capture the expected outputs.

   ```bash
   az aks list --resource-group "$RESOURCE_GROUP" --query "[].{name:name, location:location, kubernetesVersion:kubernetesVersion}" --output table
   az acr list --resource-group "$RESOURCE_GROUP" --query "[].{name:name, loginServer:loginServer, sku:sku.name}" --output table
   az keyvault list --resource-group "$RESOURCE_GROUP" --query "[].{name:name, location:location}" --output table
   ```

## Baseline deployment · Terraform track

1. Use the same variables as the Bicep track.

   ```bash
   export SUBSCRIPTION_ID="<subscription-id>"
   export RESOURCE_GROUP="<resource-group>"
   export LOCATION="westeurope"
   ```

2. Run the script contract for Terraform parity.

   ```bash
   scripts/deploy --track terraform --subscription "$SUBSCRIPTION_ID" --resource-group "$RESOURCE_GROUP" --location "$LOCATION"
   ```

3. Confirm parity with the Bicep output contract.

   ```bash
   az aks show --resource-group "$RESOURCE_GROUP" --name "<cluster-name>" --query "{name:name, workloadIdentity:securityProfile.workloadIdentity.enabled, oidcIssuer:oidcIssuerProfile.issuerUrl}" --output table
   az monitor log-analytics workspace list --resource-group "$RESOURCE_GROUP" --query "[].{name:name, location:location}" --output table
   ```

## ACR build and push

1. Resolve ACR variables and choose a tag.

   ```bash
   export ACR_LOGIN_SERVER="<acr-login-server>"
   export ACR_NAME="${ACR_LOGIN_SERVER%%.*}"
   export IMAGE_TAG="m4-$(date +%Y%m%d%H%M)"
   ```

2. Build in ACR for environments without Docker.

   ```bash
   az acr build --registry "$ACR_NAME" --image "dotnet-api:$IMAGE_TAG" apps/dotnet-api
   az acr build --registry "$ACR_NAME" --image "python-worker:$IMAGE_TAG" apps/python-worker
   az acr build --registry "$ACR_NAME" --image "node-web:$IMAGE_TAG" apps/node-web
   ```

3. If Docker is available, build and push locally.

   ```bash
   az acr login --name "$ACR_NAME"
   docker build --platform linux/amd64 -t "$ACR_LOGIN_SERVER/dotnet-api:$IMAGE_TAG" apps/dotnet-api
   docker build --platform linux/amd64 -t "$ACR_LOGIN_SERVER/python-worker:$IMAGE_TAG" apps/python-worker
   docker build --platform linux/amd64 -t "$ACR_LOGIN_SERVER/node-web:$IMAGE_TAG" apps/node-web
   docker push "$ACR_LOGIN_SERVER/dotnet-api:$IMAGE_TAG"
   docker push "$ACR_LOGIN_SERVER/python-worker:$IMAGE_TAG"
   docker push "$ACR_LOGIN_SERVER/node-web:$IMAGE_TAG"
   ```

4. Verify repositories and tags.

   ```bash
   az acr repository show-tags --name "$ACR_NAME" --repository dotnet-api --output table
   az acr repository show-tags --name "$ACR_NAME" --repository python-worker --output table
   az acr repository show-tags --name "$ACR_NAME" --repository node-web --output table
   ```

## Flux bootstrap

1. Connect kubectl.

   ```bash
   az aks get-credentials --resource-group "$RESOURCE_GROUP" --name "<cluster-name>" --overwrite-existing
   ```

2. Bootstrap the GitOps app-of-apps path.

   ```bash
   export GITOPS_REPO_URL="https://github.com/<owner>/<repo>.git"
   export GITOPS_BRANCH="main"
   export GITOPS_PATH="gitops/clusters/microhack"

   scripts/bootstrap-gitops --cluster "<cluster-name>" --resource-group "$RESOURCE_GROUP" --repo "$GITOPS_REPO_URL" --branch "$GITOPS_BRANCH" --path "$GITOPS_PATH"
   ```

3. Force an initial reconcile after the repository path is ready.

   ```bash
   flux reconcile source git flux-system --namespace flux-system
   flux get sources git -A
   flux get kustomizations -A
   ```

## Verification

1. Verify workload health.

   ```bash
   kubectl get pods -A
   kubectl get deploy,svc,ingress -A
   ```

2. Verify identity and image pull.

   ```bash
   kubectl get serviceaccount -A -o jsonpath='{range .items[*]}{.metadata.namespace}{"/"}{.metadata.name}{" => "}{.metadata.annotations.azure\.workload\.identity/client-id}{"\n"}{end}'
   kubectl describe pod -n apps -l app.kubernetes.io/name=dotnet-api | grep -E "Image:|Pulled|Service Account:"
   ```

3. Verify ingress.

   ```bash
   kubectl get ingress -A
   curl --fail --show-error --location "https://<ingress-host>/health"
   ```

4. Verify observability.

   ```bash
   kubectl get pods -n kube-system -l rsName=ama-logs
   kubectl get pods -n ama-metrics
   az monitor log-analytics workspace list --resource-group "$RESOURCE_GROUP" --output table
   ```

5. Save evidence for the as-built.

   ```bash
   flux get kustomizations -A
   az acr repository list --name "$ACR_NAME" --output table
   az aks show --resource-group "$RESOURCE_GROUP" --name "<cluster-name>" --output json
   ```
