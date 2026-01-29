#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: manage-service.sh
#
# Description:
#   Manages Devbox services with reference counting and convention-based scripts.
#
# Usage:
#   manage-service.sh <action> <service-name>
#
# Actions:
#   start  - Start the service (with reference counting)
#   stop   - Stop the service (with reference counting)
#   init   - Initialize the service
#   clean  - Clean service data
#
# Example:
#   manage-service.sh start postgresql
#   manage-service.sh init kafka
#
# Conventions:
#   Each service has a directory at services/<service-name>/ containing:
#   - ready.sh (required) - Check if service is ready
#   - init.sh (optional)  - Initialize service
#   - clean.sh (optional) - Clean service data
# ------------------------------------------------------------------------------

set -euo pipefail
trap 'echo "Script failed at line $LINENO: $BASH_COMMAND"' ERR

# Determine the base directory for devbox-scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_SCRIPTS_DIR="${DEVBOX_SCRIPTS_DIR:-$SCRIPT_DIR}"

ACTION="${1:-}"
SERVICE="${2:-}"
REF_FILE="/tmp/devbox-${SERVICE}.refcount"

if [[ -z "$SERVICE" || -z "$ACTION" ]]; then
  echo "Usage: $0 <action> <service-name>"
  echo "Actions: start, stop, init, clean"
  exit 1
fi

# Verify service directory exists
SERVICE_DIR="$DEVBOX_SCRIPTS_DIR/services/$SERVICE"
if [[ ! -d "$SERVICE_DIR" ]]; then
  echo "Error: Service '$SERVICE' not found at $SERVICE_DIR"
  exit 1
fi

# Run a service script if it exists
run_service_script() {
  local script="$SERVICE_DIR/$1.sh"
  if [[ -x "$script" ]]; then
    "$script"
  else
    echo "Error: $1.sh not found or not executable at $script"
    exit 1
  fi
}

# Check if a service script exists
has_service_script() {
  local script="$SERVICE_DIR/$1.sh"
  [[ -x "$script" ]]
}

# Reference counting functions
init_ref_file() {
  if [ ! -f "$REF_FILE" ]; then
    echo 0 > "$REF_FILE"
  fi
}

increment_ref() {
  init_ref_file
  local count
  count=$(<"$REF_FILE")
  echo $((count + 1)) > "$REF_FILE"
}

decrement_ref() {
  init_ref_file
  local count
  count=$(<"$REF_FILE")
  if (( count > 0 )); then
    echo $((count - 1)) > "$REF_FILE"
  fi
}

get_refcount() {
  init_ref_file
  cat "$REF_FILE"
}

is_service_started() {
  "$SERVICE_DIR/ready.sh" >/dev/null 2>&1
  return $?
}

wait_for_service_ready() {
  local max_retries=30
  local wait_time=0.5
  local count=0
  echo -e "\nWaiting for $SERVICE to become ready..."
  until is_service_started || false; do
    sleep "$wait_time"
    ((++count))
    if (( count >= max_retries )); then
      echo "Timeout waiting for $SERVICE to become ready."
      return 1
    fi
  done
}

case "$ACTION" in
  start)
    if ! has_service_script "ready"; then
      echo "Error: ready.sh is required for start action"
      exit 1
    fi
    if ! is_service_started; then
      rm -f "$REF_FILE"
      echo "Starting $SERVICE..."
      devbox services start "$SERVICE"
      wait_for_service_ready
    else
      count=$(get_refcount)
      if (( count == 0 )); then
        increment_ref
      fi
    fi
    increment_ref
    ;;
  stop)
    if ! has_service_script "ready"; then
      echo "Error: ready.sh is required for stop action"
      exit 1
    fi
    if is_service_started; then
      decrement_ref
      count=$(get_refcount)
      if (( count == 0 )); then
        echo "Stopping $SERVICE..."
        devbox services stop "$SERVICE"
        rm -f "$REF_FILE"
      fi
    else
      rm -f "$REF_FILE"
    fi
    ;;
  init)
    run_service_script "init"
    ;;
  clean)
    run_service_script "clean"
    ;;
  *)
    echo "Unknown action: $ACTION"
    echo "Valid actions: start, stop, init, clean"
    exit 1
    ;;
esac
