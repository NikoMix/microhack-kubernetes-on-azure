#!/usr/bin/env bash
# Summarize month-to-date Azure spend for the lab resource group.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=scripts/lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat <<'USAGE'
Usage: cost-report.sh --resource-group-name VALUE [--subscription VALUE] [-h|--help]
USAGE
}

resource_group_name=""
subscription="${AZURE_SUBSCRIPTION_ID:-}"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --resource-group-name) resource_group_name="${2:?Missing value for --resource-group-name}"; shift 2 ;;
    --subscription) subscription="${2:?Missing value for --subscription}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) log_error "Unknown argument: $1"; usage; exit 2 ;;
  esac
done
[[ -n "$resource_group_name" ]] || { log_error "--resource-group-name is required"; usage; exit 2; }
if [[ -n "$subscription" ]]; then run az account set --subscription "$subscription"; fi
subscription_id="$(az account show --query id --output tsv)"
scope="/subscriptions/${subscription_id}/resourceGroups/${resource_group_name}"
start_date="$(date '+%Y-%m-01')"
end_date="$(date '+%Y-%m-%d')"

table=""
# shellcheck disable=SC2016 # JMESPath expression is passed literally to Azure CLI; shell expansion is not desired.
if table="$(az costmanagement query --scope "$scope" --type ActualCost --timeframe Custom --time-period "from=${start_date}" "to=${end_date}" --dataset-granularity None --dataset-grouping name=ResourceType type=Dimension --dataset-aggregation name=Cost function=Sum --query 'properties.rows[].join(`|`, [to_string([1]), to_string([0])])' --output tsv 2>/dev/null)"; then
  true
else
  log_warn "az costmanagement query unavailable; falling back to az consumption usage list."
  raw_usage="$(az consumption usage list --start-date "$start_date" --end-date "$end_date" --query "[?to_string(resourceGroup)=='${resource_group_name}'].[consumedService, pretaxCost]" --output tsv 2>/dev/null || true)"
  table="$(awk -F '\t' 'NF >= 2 { totals[$1] += $2 } END { for (item in totals) printf "%s|%.6f\n", item, totals[item] }' <<<"$raw_usage")"
fi
if [[ -z "$table" ]]; then
  log_warn "No month-to-date cost data found for the resource group."
else
  printf '%-45s %12s\n' "RESOURCE TYPE" "COST"
  printf '%-45s %12s\n' "-------------" "----"
  total="0"
  while IFS=$'\t|' read -r resource_type cost; do
    [[ -n "${resource_type:-}" ]] || continue
    printf '%-45s %12.2f\n' "$resource_type" "$cost"
    total="$(awk -v a="$total" -v b="$cost" 'BEGIN { printf "%.6f", a + b }')"
  done <<<"$table"
  log_success "Month-to-date total estimate/actual: $(awk -v t="$total" 'BEGIN { printf "%.2f", t }')"
fi
log_info "Estimated daily baseline guidance (varies by SKU, region, usage, and discounts): AKS nodes, ACR Premium, Log Analytics ingestion/retention, Azure Managed Grafana, and Azure Monitor Workspace may continue to accrue cost while deployed."
