#!/usr/bin/env bash
set -euo pipefail

log_line() {
  local level="$1"
  local message="$2"
  local color reset timestamp
  timestamp="$(date '+%Y-%m-%dT%H:%M:%S%z')"
  reset='\033[0m'
  case "$level" in
    INFO) color='\033[36m' ;;
    WARN) color='\033[33m' ;;
    ERROR) color='\033[31m' ;;
    SUCCESS) color='\033[32m' ;;
    *) color='' ;;
  esac
  printf '%b[%s] [%s] %s%b\n' "$color" "$timestamp" "$level" "$message" "$reset"
}

log_info() { log_line INFO "$1"; }
log_warn() { log_line WARN "$1"; }
log_error() { log_line ERROR "$1" >&2; }
log_success() { log_line SUCCESS "$1"; }

require_command() {
  local name="$1"
  if ! command -v "$name" >/dev/null 2>&1; then
    log_error "Required command not found on PATH: $name"
    return 1
  fi
}

confirm_action() {
  local message="$1"
  local force="${2:-false}"
  local answer
  if [[ "$force" == "true" ]]; then
    return 0
  fi
  read -r -p "$message [y/N] " answer
  [[ "$answer" =~ ^([yY]|[yY][eE][sS])$ ]]
}

run() {
  log_info "$*"
  "$@"
}

run_capture() {
  log_info "$*"
  "$@"
}
