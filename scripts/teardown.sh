#!/usr/bin/env bash
# Delete billable AKS MicroHack infrastructure resources.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd -P)"
# shellcheck source=scripts/lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat <<'USAGE'
Usage: teardown.sh [--track bicep|terraform] [--resource-group-name VALUE]
                   [--subscription VALUE] [--force] [--wait] [-h|--help]
USAGE
}

track="bicep"
resource_group_name=""
subscription="${AZURE_SUBSCRIPTION_ID:-}"
force="false"
wait_for_delete="false"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --track) track="${2:?Missing value for --track}"; shift 2 ;;
    --resource-group-name) resource_group_name="${2:?Missing value for --resource-group-name}"; shift 2 ;;
    --subscription) subscription="${2:?Missing value for --subscription}"; shift 2 ;;
    --force) force="true"; shift ;;
    --wait) wait_for_delete="true"; shift ;;
    -h|--help) usage; exit 0 ;;
    *) log_error "Unknown argument: $1"; usage; exit 2 ;;
  esac
done
[[ "$track" == "bicep" || "$track" == "terraform" ]] || { log_error "--track must be bicep or terraform"; exit 2; }
if [[ -n "$subscription" ]]; then run az account set --subscription "$subscription"; fi

if [[ "$track" == "bicep" ]]; then
  [[ -n "$resource_group_name" ]] || { log_error "--resource-group-name is required for bicep teardown"; exit 2; }
  if ! az group show --name "$resource_group_name" --output none >/dev/null 2>&1; then
    log_success "Resource group '${resource_group_name}' does not exist; nothing to delete."
    exit 0
  fi
  if ! confirm_action "Delete resource group '${resource_group_name}' and all billable lab resources?" "$force"; then
    log_warn "Teardown cancelled."
    exit 0
  fi
  args=(group delete --name "$resource_group_name" --yes)
  if [[ "$wait_for_delete" != "true" ]]; then args+=(--no-wait); fi
  run az "${args[@]}"
else
  if ! confirm_action "Destroy Terraform-managed lab resources?" "$force"; then
    log_warn "Teardown cancelled."
    exit 0
  fi
  run terraform "-chdir=${REPO_ROOT}/infra/terraform" destroy -auto-approve
fi
log_warn "Soft-deleted Key Vaults with purge protection enabled persist until their retention window expires. This is intentional best practice and cannot be purged early."
log_success "Teardown command completed."
