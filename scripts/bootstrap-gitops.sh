#!/usr/bin/env bash
# Connect Flux v2 GitOps to an existing AKS cluster using the AKS GitOps extension.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
# shellcheck source=scripts/lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat <<'USAGE'
Usage: bootstrap-gitops.sh --resource-group-name VALUE --cluster-name VALUE [--subscription VALUE]
                            [--gitops-repo-url VALUE] [--branch VALUE]
                            [--gitops-path VALUE] [--force] [-h|--help]
USAGE
}

resource_group_name=""
cluster_name=""
subscription="${AZURE_SUBSCRIPTION_ID:-}"
gitops_repo_url=""
branch="main"
gitops_path="./gitops/clusters/microhack"
force="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --resource-group-name) resource_group_name="${2:?Missing value for --resource-group-name}"; shift 2 ;;
    --cluster-name) cluster_name="${2:?Missing value for --cluster-name}"; shift 2 ;;
    --subscription) subscription="${2:?Missing value for --subscription}"; shift 2 ;;
    --gitops-repo-url) gitops_repo_url="${2:?Missing value for --gitops-repo-url}"; shift 2 ;;
    --branch) branch="${2:?Missing value for --branch}"; shift 2 ;;
    --gitops-path) gitops_path="${2:?Missing value for --gitops-path}"; shift 2 ;;
    --force) force="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) log_error "Unknown argument: $1"; usage; exit 2 ;;
  esac
done
[[ -n "$resource_group_name" && -n "$cluster_name" ]] || { log_error "--resource-group-name and --cluster-name are required"; usage; exit 2; }
if [[ -n "$subscription" ]]; then run az account set --subscription "$subscription"; fi
if [[ -z "$gitops_repo_url" ]]; then
  gitops_repo_url="$(git -C "$REPO_ROOT" remote get-url origin 2>/dev/null || true)"
  [[ -n "$gitops_repo_url" ]] || { log_error "--gitops-repo-url was not provided and git remote get-url origin failed"; exit 1; }
fi

run az aks get-credentials --resource-group "$resource_group_name" --name "$cluster_name" --overwrite-existing
run az extension add --name k8s-configuration --upgrade
run az extension add --name k8s-extension --upgrade
run az provider register --namespace Microsoft.KubernetesConfiguration
run az provider show --namespace Microsoft.KubernetesConfiguration --query registrationState --output tsv

configuration_name="microhack-flux"
if az k8s-configuration flux show --resource-group "$resource_group_name" --cluster-name "$cluster_name" --cluster-type managedClusters --name "$configuration_name" --output none >/dev/null 2>&1; then
  if ! confirm_action "Flux configuration '${configuration_name}' already exists. Delete and recreate it?" "$force"; then
    log_warn "Existing Flux configuration left unchanged."
    exit 0
  fi
  run az k8s-configuration flux delete --resource-group "$resource_group_name" --cluster-name "$cluster_name" --cluster-type managedClusters --name "$configuration_name" --yes
fi
run az k8s-configuration flux create \
  --resource-group "$resource_group_name" \
  --cluster-name "$cluster_name" \
  --cluster-type managedClusters \
  --name "$configuration_name" \
  --namespace flux-system \
  --scope cluster \
  --url "$gitops_repo_url" \
  --branch "$branch" \
  --kustomization "name=cluster path=${gitops_path} prune=true" \
  --sync-interval 5m

# Fallback option for environments that cannot use the AKS extension: flux bootstrap git, when the flux CLI is installed.
log_success "Flux GitOps configuration is connected."
