#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: ready.sh (Kafka)
#
# Description:
#   Checks if Kafka broker is ready to accept connections.
#
# Environment:
#   KAFKA_HOST - Kafka host (default: localhost)
#   KAFKA_PORT - Kafka broker port (default: 9092)
# ------------------------------------------------------------------------------

set -e

KAFKA_HOST="${KAFKA_HOST:-localhost}"
KAFKA_PORT="${KAFKA_PORT:-9092}"

kafka-broker-api-versions.sh --bootstrap-server "$KAFKA_HOST:$KAFKA_PORT" >/dev/null 2>&1
