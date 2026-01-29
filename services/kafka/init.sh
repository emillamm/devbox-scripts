#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: init.sh (Kafka)
#
# Description:
#   Initializes Kafka storage and configuration.
#   Generates cluster ID and formats storage if not already done.
#
# Environment:
#   KAFKA_BROKERS          - Kafka broker address (default: localhost:9092)
#   KAFKA_CONTROLLER_PORT  - Kafka controller port (default: 9093)
#   KAFKA_DATA_DIR         - Kafka data directory (default: $DEVBOX_PROJECT_ROOT/.devbox/kafka-data)
#   KAFKA_CONFIG_TEMPLATE  - Path to kafka.properties template (default: $DEVBOX_PROJECT_ROOT/kafka.properties)
# ------------------------------------------------------------------------------

set -euo pipefail

KAFKA_BROKERS="${KAFKA_BROKERS:-localhost:9092}"
KAFKA_HOST="${KAFKA_BROKERS%:*}"
KAFKA_PORT="${KAFKA_BROKERS#*:}"
KAFKA_CONTROLLER_PORT="${KAFKA_CONTROLLER_PORT:-9093}"
KAFKA_DATA_DIR="${KAFKA_DATA_DIR:-$DEVBOX_PROJECT_ROOT/.devbox/kafka-data}"
KAFKA_CONFIG_TEMPLATE="${KAFKA_CONFIG_TEMPLATE:-$DEVBOX_PROJECT_ROOT/kafka.properties}"

KAFKA_CONFIG="$KAFKA_DATA_DIR/server.properties"
CLUSTER_ID_FILE="$KAFKA_DATA_DIR/cluster_id"

mkdir -p "$KAFKA_DATA_DIR"

# Generate runtime config with actual values
sed -e "s|__KAFKA_DATA_DIR__|$KAFKA_DATA_DIR|g" \
    -e "s|__KAFKA_HOST__|$KAFKA_HOST|g" \
    -e "s|__KAFKA_PORT__|$KAFKA_PORT|g" \
    -e "s|__KAFKA_CONTROLLER_PORT__|$KAFKA_CONTROLLER_PORT|g" \
    "$KAFKA_CONFIG_TEMPLATE" > "$KAFKA_CONFIG"

# Generate cluster ID if it doesn't exist
if [ ! -f "$CLUSTER_ID_FILE" ]; then
  kafka-storage.sh random-uuid > "$CLUSTER_ID_FILE"
fi

CLUSTER_ID=$(cat "$CLUSTER_ID_FILE")

# Format storage if not already formatted
if [ ! -f "$KAFKA_DATA_DIR/__cluster_metadata-0/partition.metadata" ]; then
  kafka-storage.sh format -t "$CLUSTER_ID" -c "$KAFKA_CONFIG" --ignore-formatted
fi

echo "Kafka initialized with cluster ID: $CLUSTER_ID"
