# Troubleshooting

Use this guide for fast recovery during the Module B MicroHack. Prefer the smallest safe fix that gets learners back to evidence production.

## General triage flow

1. Confirm the current subscription, resource group, cluster and namespace.
2. Reproduce the symptom with one command.
3. Classify the issue as access, quota, cluster context, deployment, networking, identity, observability or Copilot/MCP.
4. Apply the fast fix.
5. Capture any unresolved risk in the remediation log so it can feed M2, M5 or M6 evidence.

```bash
az account show --query "{subscription:id, tenant:tenantId, user:user.name}" -o table
kubectl config current-context
kubectl get nodes
kubectl get pods -A
```

## Auth, az login and subscription

| Symptom | Likely cause | Fast fix |
| --- | --- | --- |
| `az` says no subscriptions were found | Wrong tenant, guest account not selected or no RBAC assignment | Sign in to the expected tenant and confirm subscription access. |
| Commands target the wrong subscription | Default subscription drift | Set the subscription explicitly before running lab commands. |
| Azure portal works but CLI fails | Conditional access, stale token or old Azure CLI profile | Clear the account and sign in again. |
| Learner can view but not deploy | Reader role only | Assign Contributor or Owner at the lab subscription or resource-group scope. |

```bash
az login --tenant <tenant-id>
az account list -o table
az account set --subscription <subscription-id>
az role assignment list --assignee <user-principal-name> --scope /subscriptions/<subscription-id> -o table
az account clear
az login --tenant <tenant-id>
```

## Quota and West Europe region

| Symptom | Likely cause | Fast fix |
| --- | --- | --- |
| AKS or node pool deployment fails with quota error | Insufficient regional vCPU quota in `westeurope` | Reduce node count or VM size, use a pre-approved subscription or request quota. |
| SKU not available | VM family unavailable in West Europe for the subscription | Switch to an approved SKU from the preflight list. |
| Deployment starts but times out | Regional capacity pressure or quota throttling | Retry once, then switch to the trainer reference environment. |

```bash
az vm list-usage --location westeurope -o table
az vm list-skus --location westeurope --size Standard_D --all -o table
az aks get-versions --location westeurope -o table
```

## AKS credentials and context

| Symptom | Likely cause | Fast fix |
| --- | --- | --- |
| `kubectl` uses an old cluster | Current context points to another environment | Set the expected context after fetching credentials. |
| `kubectl` returns unauthorized | Missing Azure RBAC role, stale token or missing `kubelogin` conversion | Refresh credentials and convert kubeconfig for Azure CLI login. |
| `kubectl get nodes` times out | Private cluster or network path unavailable | Use the approved jump host, Codespace or network path for the lab. |
| Namespace commands fail | Wrong namespace | Set or pass the namespace explicitly. |

```bash
az aks get-credentials --resource-group <resource-group> --name <cluster-name> --overwrite-existing
kubelogin convert-kubeconfig -l azurecli
kubectl config get-contexts
kubectl config use-context <context-name>
kubectl get nodes -o wide
kubectl config set-context --current --namespace <namespace>
```

## ACR pull and identity

| Symptom | Likely cause | Fast fix |
| --- | --- | --- |
| Pod shows `ImagePullBackOff` | AKS kubelet identity lacks ACR pull rights | Attach ACR to AKS or assign `AcrPull` to the kubelet identity. |
| Image tag not found | Wrong tag, repository or login server | List tags in ACR and update the manifest or Helm values. |
| Pull succeeds locally but fails in AKS | Local Docker auth masks missing cluster identity | Verify AKS managed identity permissions on ACR. |
| Private registry DNS fails | Network or private endpoint resolution issue | Test registry resolution and use the approved network path. |

```bash
az acr repository list --name <acr-name> -o table
az acr repository show-tags --name <acr-name> --repository <repository> -o table
az aks update --resource-group <resource-group> --name <cluster-name> --attach-acr <acr-name>
kubectl describe pod <pod-name> -n <namespace>
```

## Flux not reconciling

| Symptom | Likely cause | Fast fix |
| --- | --- | --- |
| Kustomization is suspended | Learner or previous run suspended reconciliation | Resume the Kustomization. |
| Source artifact is stale | Git credentials, branch or path issue | Reconcile the source and inspect source-controller logs. |
| HelmRelease not ready | Chart version, values or dependency failure | Inspect HelmRelease events and helm-controller logs. |
| Applied manifests differ from Git | Wrong branch or path | Check Flux source URL, branch and Kustomization path. |

```bash
flux get sources git -A
flux get kustomizations -A
flux reconcile source git <source-name> -n <namespace>
flux reconcile kustomization <kustomization-name> -n <namespace> --with-source
kubectl logs -n flux-system deployment/source-controller --tail=100
kubectl logs -n flux-system deployment/kustomize-controller --tail=100
```

## Ingress, DNS and certificates

| Symptom | Likely cause | Fast fix |
| --- | --- | --- |
| HTTP endpoint returns 404 | Route, host or ingress class mismatch | Verify host rules, service name and ingress class. |
| Endpoint times out | Load balancer, gateway or firewall path not ready | Check ingress controller service and Azure public IP or gateway status. |
| TLS certificate not issued | DNS not pointing to ingress, issuer failure or ACME rate limit | Validate DNS first, then inspect certificate resources and issuer logs. |
| Browser shows certificate mismatch | Hostname differs from certificate subject | Use the exact DNS name configured in the certificate. |

```bash
kubectl get ingress -A
kubectl describe ingress <ingress-name> -n <namespace>
kubectl get svc -A | grep -i ingress
kubectl get certificate,issuer,clusterissuer -A
kubectl describe certificate <certificate-name> -n <namespace>
curl -vk https://<app-hostname>/health
```

## Workload Identity

| Symptom | Likely cause | Fast fix |
| --- | --- | --- |
| Pod cannot get Azure token | Service account annotations missing or wrong client ID | Compare service account annotations with the federated identity credential. |
| Token exchange fails | AKS OIDC issuer mismatch | Verify the cluster OIDC issuer and federated credential subject. |
| App receives forbidden from Azure resource | Managed identity lacks data-plane permission | Assign the required role at the correct scope. |
| Works after restart only | Pod started before identity annotations were applied | Restart pods after fixing the service account. |

```bash
az aks show --resource-group <resource-group> --name <cluster-name> --query oidcIssuerProfile.issuerUrl -o tsv
kubectl describe serviceaccount <service-account> -n <namespace>
az identity federated-credential list --resource-group <resource-group> --identity-name <identity-name> -o table
kubectl rollout restart deployment/<deployment-name> -n <namespace>
```

## Key Vault CSI

| Symptom | Likely cause | Fast fix |
| --- | --- | --- |
| Secret volume is empty | SecretProviderClass references wrong vault, object or identity | Inspect SecretProviderClass and provider logs. |
| Mount fails with forbidden | Identity lacks Key Vault permissions or RBAC role | Assign Key Vault Secrets User or equivalent data-plane access. |
| App sees old secret | Rotation interval or app reload behavior | Restart workload or validate CSI rotation settings. |
| CSI driver pods not running | Add-on or Helm installation issue | Check CSI provider pods and events. |

```bash
kubectl get secretproviderclass -A
kubectl describe secretproviderclass <spc-name> -n <namespace>
kubectl get pods -n kube-system | grep -i csi
kubectl logs -n kube-system -l app=secrets-store-csi-driver --tail=100
az keyvault secret show --vault-name <key-vault-name> --name <secret-name>
```

## Container Insights not flowing

| Symptom | Likely cause | Fast fix |
| --- | --- | --- |
| No container logs in Log Analytics | Monitoring add-on disabled or workspace misconfigured | Verify monitoring profile and workspace resource ID. |
| Metrics appear but logs do not | Agent config or ingestion delay | Wait a few minutes, then check AMA pods and logs. |
| Dashboards empty | Wrong time range, workspace or cluster | Confirm workspace, query scope and time range. |
| Alerts do not fire | Alert rule disabled or wrong signal | Inspect alert rule scope and criteria. |

```bash
az aks show --resource-group <resource-group> --name <cluster-name> --query addonProfiles.omsagent -o json
kubectl get pods -n kube-system | grep -E "ama|oms|monitor"
kubectl logs -n kube-system -l rsName=ama-logs --tail=100
az monitor log-analytics workspace list -o table
```

## k6 and Chaos Studio access

| Symptom | Likely cause | Fast fix |
| --- | --- | --- |
| `k6` command not found | Tool missing from learner environment | Use Codespaces, install from approved image or let the pair partner run it. |
| k6 cannot reach service | Ingress/DNS issue or private endpoint | Test `/health` with `curl` from the same environment. |
| Chaos experiment cannot start | Missing RBAC or provider registration | Verify role assignments and provider registration. |
| Target not onboarded to Chaos Studio | AKS resource not enabled as a chaos target | Enable the target or use the trainer reference evidence. |

```bash
k6 version
curl -vk https://<app-hostname>/health
az provider register --namespace Microsoft.Chaos
az provider show --namespace Microsoft.Chaos --query registrationState -o tsv
az role assignment list --scope <aks-resource-id> -o table
```

## Copilot and MCP connectivity

| Symptom | Likely cause | Fast fix |
| --- | --- | --- |
| AKS Engagement Copilot agent unavailable | WS4 assets not installed or extension not enabled | Use the manual lab path and record the gap. |
| Skill not found | Skill package missing or renamed | Use the closest manual section and avoid inventing skill output. |
| Azure MCP cannot access resources | Authentication, subscription or tenant mismatch | Re-authenticate and confirm subscription context. |
| GitHub MCP cannot read repo | GitHub auth or repository permission issue | Confirm repo access and use browser or CLI fallback if approved. |
| Microsoft Docs MCP returns no result | Connectivity or query too narrow | Broaden the query or use Microsoft Learn manually. |

```bash
az account show -o table
gh auth status
curl -I https://learn.microsoft.com/
```

## Escalation criteria

Escalate or switch to trainer reference evidence when any of these conditions are true.

- A quota, RBAC or tenant issue cannot be fixed within 10 minutes.
- A learner environment cannot reach a private cluster path.
- A deployment issue would consume protected M5 or M6 time.
- Copilot/MCP is unavailable and the manual path has already produced enough evidence.
- A fix would require changing files outside the learner-owned lab scope.
