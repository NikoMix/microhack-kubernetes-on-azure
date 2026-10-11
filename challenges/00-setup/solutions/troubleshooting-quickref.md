# M00 troubleshooting quick reference

Use this trainer-only quick reference when learners are blocked during setup.

## Azure login and subscription

| Symptom | Likely cause | Action |
| --- | --- | --- |
| Subscription missing | Wrong tenant selected | Run `az login --tenant <tenant-id>` and retry `az account list`. |
| Preflight shows wrong subscription | Default subscription mismatch | Run `az account set --subscription <subscription-id>`. |
| Authorization failure during deploy | Role assignment missing | Move learner to a prepared subscription or ask the Azure owner to grant the required role. |

## Quota and region

| Symptom | Likely cause | Action |
| --- | --- | --- |
| West Europe capacity failure | Regional quota insufficient | Use the trainer reserve subscription or reduce node count only if the trainer approves. |
| Provider registration error | Resource provider not registered | Register the provider if policy allows, then rerun preflight. |

## Kubernetes context

| Symptom | Likely cause | Action |
| --- | --- | --- |
| `kubectl` points to another cluster | Current context mismatch | Run `kubectl config get-contexts`, then rerun `az aks get-credentials --overwrite-existing`. |
| `kubectl get nodes` is forbidden | RBAC propagation or wrong identity | Confirm the Azure user, wait briefly, and retry. Check Entra group membership if used. |
| Cluster API timeout | Network path or private endpoint issue | Confirm the learner is in the expected dev container or network path. |

## Copilot and MCP

| Symptom | Likely cause | Action |
| --- | --- | --- |
| Azure MCP cannot see subscription | Expired Azure token | Refresh `az login` and reconnect Azure MCP. |
| GitHub MCP cannot see repository | GitHub auth scope or access issue | Re-authenticate GitHub and confirm repository access. |
| Microsoft Docs MCP returns no results | Network or service issue | Retry and use browser documentation as manual fallback. |
