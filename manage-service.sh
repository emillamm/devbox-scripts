#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: manage-service.sh
#
# Description:
#   Starts or stops a Devbox-managed service with reference counting.
#   Useful when multiple processes depend on the same service (e.g. PostgreSQL).
#
#   - On "start": Increments a usage counter and only starts the service if it's not running.
#   - On "stop": Decrements the usage counter and only stops the service when it reaches 0.
#
# Usage:
#   ./manage-service.sh <start|stop> <service-name>
#
# Example:
#   ./manage-service.sh start postgresql
#   ./manage-service.sh stop postgresql
#
# Conventions:
#   - Each service must have a ready.sh script at services/<service-name>/ready.sh
#   - The ready.sh script should exit 0 if the service is ready, non-zero otherwise
#   - Reference count is stored in /tmp and cleaned up automatically
#
# Environment:
#   DEVBOX_SCRIPTS_DIR - Base directory for devbox-scripts (default: script's directory)
# ------------------------------------------------------------------------------

set -euo pipefail
trap 'echo "Script failed at line $LINENO: $BASH_COMMAND"' ERR

# Determine the base directory for devbox-scripts
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEVBOX_SCRIPTS_DIR="${DEVBOX_SCRIPTS_DIR:-$SCRIPT_DIR}"

ACTION="${1:-}"
SERVICE="${2:-}"
REF_FILE="/tmp/devbox-${SERVICE}.refcount"

if [[ -z "$SERVICE" || ( "$ACTION" != "start" && "$ACTION" != "stop" ) ]]; then
  echo "Usage: $0 <start|stop> <service-name>"
  exit 1
fi

# Verify service directory exists
SERVICE_DIR="$DEVBOX_SCRIPTS_DIR/services/$SERVICE"
if [[ ! -d "$SERVICE_DIR" ]]; then
  echo "Error: Service '$SERVICE' not found at $SERVICE_DIR"
  exit 1
fi

# Verify ready.sh exists
READY_SCRIPT="$SERVICE_DIR/ready.sh"
if [[ ! -x "$READY_SCRIPT" ]]; then
  echo "Error: ready.sh not found or not executable at $READY_SCRIPT"
  exit 1
fi

# Make sure the counter file exists and is safe to read/write
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
  "$READY_SCRIPT" >/dev/null 2>&1
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

if [[ "$ACTION" == "start" ]]; then
  if ! is_service_started; then
    rm -f "$REF_FILE"
    echo "Starting $SERVICE..."
    devbox services start "$SERVICE"
    wait_for_service_ready
  else
    # If service is already started and refcount is 0, make sure to set it to 1
    # so the services isn't terminated by the calling process.
    count=$(get_refcount)
    if (( count == 0 )); then
      increment_ref
    fi
  fi
  increment_ref
elif [[ "$ACTION" == "stop" ]]; then
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
fi
