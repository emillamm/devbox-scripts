#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: init.sh (Kafka)
#
# Description:
#   Initializes Kafka storage and configuration.
#   Generates cluster ID and formats storage if not already done.
#
# Environment:
#   KAFKA_DATA_DIR        - Kafka data directory (required)
#   KAFKA_CONFIG_TEMPLATE - Path to kafka.properties template (required)
#                           Template should use __KAFKA_DATA_DIR__ as placeholder
# ------------------------------------------------------------------------------

set -ex

if [[ -z "$KAFKA_DATA_DIR" ]]; then
  echo "Error: KAFKA_DATA_DIR environment variable is required"
  exit 1
fi

if [[ -z "$KAFKA_CONFIG_TEMPLATE" ]]; then
  echo "Error: KAFKA_CONFIG_TEMPLATE environment variable is required"
  exit 1
fi

KAFKA_CONFIG="$KAFKA_DATA_DIR/server.properties"
CLUSTER_ID_FILE="$KAFKA_DATA_DIR/cluster_id"

mkdir -p "$KAFKA_DATA_DIR"

# Generate runtime config with actual paths
sed "s|__KAFKA_DATA_DIR__|$KAFKA_DATA_DIR|g" "$KAFKA_CONFIG_TEMPLATE" > "$KAFKA_CONFIG"

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
