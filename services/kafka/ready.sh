#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: ready.sh (Kafka)
#
# Description:
#   Checks if Kafka broker is ready to accept connections.
#
# Environment:
#   KAFKA_BOOTSTRAP_SERVER - Kafka bootstrap server (default: localhost:29092)
# ------------------------------------------------------------------------------

set -e

KAFKA_BOOTSTRAP_SERVER="${KAFKA_BOOTSTRAP_SERVER:-localhost:29092}"

kafka-broker-api-versions.sh --bootstrap-server "$KAFKA_BOOTSTRAP_SERVER" >/dev/null 2>&1
