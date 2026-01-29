#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: clean.sh (Kafka)
#
# Description:
#   Removes all Kafka data. Service must be stopped first.
#
# Environment:
#   KAFKA_DATA_DIR     - Kafka data directory (default: $DEVBOX_PROJECT_ROOT/.devbox/kafka-data)
#   DEVBOX_SCRIPTS_DIR - Base directory for devbox-scripts (required)
# ------------------------------------------------------------------------------

set -euo pipefail

KAFKA_DATA_DIR="${KAFKA_DATA_DIR:-$DEVBOX_PROJECT_ROOT/.devbox/kafka-data}"
READY_SCRIPT="$DEVBOX_SCRIPTS_DIR/services/kafka/ready.sh"

if ! "$READY_SCRIPT" 2>/dev/null; then
  rm -rf "$KAFKA_DATA_DIR"
  echo "Kafka data successfully cleaned"
else
  echo "Kafka is running. Service must be stopped before you can clean the data."
  exit 1
fi
