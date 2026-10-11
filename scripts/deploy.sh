#!/usr/bin/env bash
# Deploy or preview the AKS MicroHack infrastructure using Bicep or Terraform.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
# shellcheck source=scripts/lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat <<'USAGE'
Usage: deploy.sh [--track bicep|terraform] [--action whatif|deploy] [--location VALUE]
                 [--environment VALUE] [--workload-name VALUE] [--resource-group-name VALUE]
                 [--subscription VALUE] [--force] [-h|--help]
USAGE
}

track="bicep"
action="whatif"
location="westeurope"
environment="dev"
workload_name="mhaks"
resource_group_name=""
subscription="${AZURE_SUBSCRIPTION_ID:-}"
force="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --track) track="${2:?Missing value for --track}"; shift 2 ;;
    --action) action="${2:?Missing value for --action}"; shift 2 ;;
    --location) location="${2:?Missing value for --location}"; shift 2 ;;
    --environment) environment="${2:?Missing value for --environment}"; shift 2 ;;
    --workload-name) workload_name="${2:?Missing value for --workload-name}"; shift 2 ;;
    --resource-group-name) resource_group_name="${2:?Missing value for --resource-group-name}"; shift 2 ;;
    --subscription) subscription="${2:?Missing value for --subscription}"; shift 2 ;;
    --force) force="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) log_error "Unknown argument: $1"; usage; exit 2 ;;
  esac
done
[[ "$track" == "bicep" || "$track" == "terraform" ]] || { log_error "--track must be bicep or terraform"; exit 2; }
[[ "$action" == "whatif" || "$action" == "deploy" ]] || { log_error "--action must be whatif or deploy"; exit 2; }

if [[ -n "$subscription" ]]; then run az account set --subscription "$subscription"; fi
if [[ "$action" == "deploy" ]]; then
  sub_id="$(az account show --query id --output tsv)"
  if ! confirm_action "Deploy ${track} infrastructure to subscription ${sub_id}?" "$force"; then
    log_warn "Deployment cancelled."
    exit 0
  fi
fi

deployment_name="${workload_name}-${environment}-$(date '+%Y%m%d%H%M%S')"
if [[ "$track" == "bicep" ]]; then
  args=(deployment sub create --name "$deployment_name" --location "$location" --template-file "${REPO_ROOT}/infra/bicep/main.bicep" --parameters "${REPO_ROOT}/infra/bicep/main.bicepparam" --parameters "location=${location}" "environment=${environment}" "workloadName=${workload_name}")
  if [[ -n "$resource_group_name" ]]; then args+=("resourceGroupName=${resource_group_name}"); fi
  if [[ "$action" == "whatif" ]]; then args+=(--what-if); fi
  run az "${args[@]}"
  if [[ "$action" == "deploy" ]]; then
    output_tsv="$(az deployment sub show --name "$deployment_name" --query '[properties.outputs.resourceGroupName.value,properties.outputs.aksClusterName.value,properties.outputs.acrLoginServer.value,properties.outputs.grafanaEndpoint.value,properties.outputs.getCredentialsCommand.value]' --output tsv)"
    IFS=$'\t' read -r out_rg out_aks out_acr out_grafana out_credentials <<<"$output_tsv"
    printf 'ResourceGroup: %s\nClusterName: %s\nAcrLoginServer: %s\nGrafanaEndpoint: %s\nGetCredentials: %s\n' "$out_rg" "$out_aks" "$out_acr" "$out_grafana" "$out_credentials"
  fi
else
  tf_dir="${REPO_ROOT}/infra/terraform"
  var_args=(-var "location=${location}" -var "environment=${environment}" -var "workload_name=${workload_name}")
  if [[ -n "$resource_group_name" ]]; then var_args+=(-var "resource_group_name=${resource_group_name}"); fi
  run terraform "-chdir=${tf_dir}" init -input=false
  if [[ "$action" == "whatif" ]]; then
    run terraform "-chdir=${tf_dir}" plan -input=false -out=tfplan "${var_args[@]}"
  else
    run terraform "-chdir=${tf_dir}" apply -input=false -auto-approve "${var_args[@]}"
    out_rg="$(terraform "-chdir=${tf_dir}" output -raw resource_group_name)"
    out_aks="$(terraform "-chdir=${tf_dir}" output -raw aks_cluster_name)"
    out_acr="$(terraform "-chdir=${tf_dir}" output -raw acr_login_server)"
    out_grafana="$(terraform "-chdir=${tf_dir}" output -raw grafana_endpoint)"
    printf 'ResourceGroup: %s\nClusterName: %s\nAcrLoginServer: %s\nGrafanaEndpoint: %s\nGetCredentials: az aks get-credentials --resource-group %s --name %s --overwrite-existing\n' "$out_rg" "$out_aks" "$out_acr" "$out_grafana" "$out_rg" "$out_aks"
  fi
fi
log_success "${track} ${action} completed."
