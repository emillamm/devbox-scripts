#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: ready.sh (Kafka)
#
# Description:
#   Checks if Kafka broker is ready to accept connections.
#
# Environment:
#   KAFKA_BROKERS - Kafka broker address (default: localhost:9092)
# ------------------------------------------------------------------------------

set -euo pipefail

KAFKA_BROKERS="${KAFKA_BROKERS:-localhost:9092}"

kafka-broker-api-versions.sh --bootstrap-server "$KAFKA_BROKERS" >/dev/null 2>&1
