#!/usr/bin/env bash
# Validate local and Azure readiness for the AKS MicroHack infrastructure lab.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
# shellcheck source=scripts/lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

usage() {
  cat <<'USAGE'
Usage: preflight.sh [--subscription VALUE] [--location VALUE] [--track bicep|terraform] [-h|--help]

Validates required CLIs, Azure login, region availability, and AKS vCPU quota.
Defaults: --location westeurope, --track bicep, --subscription from AZURE_SUBSCRIPTION_ID.
USAGE
}

subscription="${AZURE_SUBSCRIPTION_ID:-}"
location="westeurope"
track="bicep"
while [[ $# -gt 0 ]]; do
  case "$1" in
    --subscription) subscription="${2:?Missing value for --subscription}"; shift 2 ;;
    --location) location="${2:?Missing value for --location}"; shift 2 ;;
    --track) track="${2:?Missing value for --track}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) log_error "Unknown argument: $1"; usage; exit 2 ;;
  esac
done
if [[ "$track" != "bicep" && "$track" != "terraform" ]]; then
  log_error "--track must be bicep or terraform"
  exit 2
fi

checks=()
hard_failures=0
add_check() {
  local name="$1" status="$2" detail="$3" hard="${4:-false}"
  checks+=("${name}|${status}|${detail}")
  if [[ "$status" == "FAIL" && "$hard" == "true" ]]; then
    hard_failures=$((hard_failures + 1))
  fi
}

for cli in az kubectl helm; do
  if command -v "$cli" >/dev/null 2>&1; then
    add_check "CLI: $cli" PASS "Found on PATH" true
  else
    add_check "CLI: $cli" FAIL "Missing from PATH" true
  fi
done
if [[ "$track" == "terraform" ]]; then
  if command -v terraform >/dev/null 2>&1; then add_check "CLI: terraform" PASS "Found on PATH" true; else add_check "CLI: terraform" FAIL "Missing from PATH" true; fi
else
  if command -v az >/dev/null 2>&1 && az bicep version >/dev/null 2>&1; then add_check "CLI: bicep" PASS "az bicep is available" true; else add_check "CLI: bicep" FAIL "az bicep version failed" true; fi
fi
for optional_cli in gh flux; do
  if command -v "$optional_cli" >/dev/null 2>&1; then add_check "Optional CLI: $optional_cli" PASS "Found on PATH" false; else add_check "Optional CLI: $optional_cli" WARN "Missing; optional workflows may be unavailable" false; fi
done

if [[ -n "$subscription" ]] && command -v az >/dev/null 2>&1; then
  run az account set --subscription "$subscription"
fi
if account_tsv="$(az account show --query '[name,id,tenantId]' --output tsv 2>/dev/null)"; then
  IFS=$'\t' read -r sub_name sub_id tenant_id <<<"$account_tsv"
  add_check "Azure login" PASS "${sub_name} (${sub_id}), tenant ${tenant_id}" true
  log_info "Using subscription '${sub_name}' (${sub_id}), tenant ${tenant_id}."
else
  add_check "Azure login" FAIL "Azure CLI is not logged in" true
fi

if location_count="$(az account list-locations --query "[?name=='${location}'] | length(@)" --output tsv 2>/dev/null)" && [[ "${location_count:-0}" -gt 0 ]]; then
  add_check "Azure region" PASS "${location} is valid" true
else
  add_check "Azure region" FAIL "${location} is not a valid Azure region for this account" true
fi

quota_line=""
for quota_name in "Standard DDSv5 Family vCPUs" "Standard Dv5 Family vCPUs" "Total Regional vCPUs"; do
  quota_line="$(az vm list-usage --location "$location" --query "[?name.localizedValue=='${quota_name}'].[currentValue,limit,name.localizedValue] | [0]" --output tsv 2>/dev/null || true)"
  [[ -n "$quota_line" ]] && break
done
if [[ -n "$quota_line" ]]; then
  IFS=$'\t' read -r current_value limit_value quota_display_name <<<"$quota_line"
  available=$((limit_value - current_value))
  if [[ "$available" -ge 16 ]]; then add_check "AKS vCPU quota" PASS "${available} available in ${quota_display_name}" false; else add_check "AKS vCPU quota" WARN "Only ${available} vCPUs available in ${quota_display_name}; 16 recommended" false; fi
else
  add_check "AKS vCPU quota" WARN "Unable to query relevant Dv5/DDv5 quota" false
fi

log_info "Preflight summary:"
printf '%-28s %-7s %s\n' "CHECK" "STATUS" "DETAIL"
printf '%-28s %-7s %s\n' "-----" "------" "------"
for row in "${checks[@]}"; do
  IFS='|' read -r name status detail <<<"$row"
  printf '%-28s %-7s %s\n' "$name" "$status" "$detail"
done
if [[ "$hard_failures" -gt 0 ]]; then
  log_error "Preflight failed with ${hard_failures} hard failure(s)."
  exit 1
fi
log_success "Preflight passed."
