#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: start.sh (Kafka)
#
# Description:
#   Starts the Kafka server.
#
# Environment:
#   KAFKA_DATA_DIR - Kafka data directory (default: $DEVBOX_PROJECT_ROOT/.devbox/kafka-data)
# ------------------------------------------------------------------------------

set -e

KAFKA_DATA_DIR="${KAFKA_DATA_DIR:-$DEVBOX_PROJECT_ROOT/.devbox/kafka-data}"
KAFKA_CONFIG="$KAFKA_DATA_DIR/server.properties"

if [[ ! -f "$KAFKA_CONFIG" ]]; then
  echo "Error: Kafka config not found at $KAFKA_CONFIG"
  echo "Run the init script first."
  exit 1
fi

exec kafka-server-start.sh "$KAFKA_CONFIG"
