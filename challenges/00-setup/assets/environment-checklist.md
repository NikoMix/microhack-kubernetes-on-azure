# Environment checklist

Use this checklist before Module 0 begins or when helping a learner recover their environment.

## Tooling

| Check | Expected result | Command or location |
| --- | --- | --- |
| Azure CLI | Installed and authenticated during lab | `az version` |
| kubectl | Client installed | `kubectl version --client=true` |
| Helm | Client installed | `helm version` |
| Bicep | CLI available for primary deployment track | `bicep --version` |
| Terraform | CLI available for parity track discussions | `terraform version` |
| GitHub CLI | Installed and authenticated if prompted | `gh --version` |
| Repository workspace | Open in Codespaces or dev container | Terminal starts at repository root |

## Azure access

- The learner can sign in with `az login`.
- The assigned subscription appears in `az account list --output table`.
- The assigned subscription can deploy resources in West Europe.
- The learner has enough permission to deploy the AKS secure baseline.
- Regional quota is available for the configured node pools and supporting services.

## Kubernetes access

- `az aks get-credentials` succeeds for `<resource-group>` and `<cluster-name>`.
- `kubectl config current-context` names the lab AKS cluster.
- `kubectl get nodes` returns `Ready` nodes.

## Copilot and MCP access

- GitHub Copilot Chat is available.
- The AKS Engagement Copilot agent can be selected when present.
- Azure MCP authenticates to the selected subscription.
- GitHub MCP can inspect the repository context.
- Microsoft Docs MCP can retrieve AKS documentation.
