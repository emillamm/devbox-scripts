#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: clean.sh (PostgreSQL)
#
# Description:
#   Removes all PostgreSQL data. Service must be stopped first.
#
# Environment:
#   PGDATA           - PostgreSQL data directory (required)
#   DEVBOX_SCRIPTS_DIR - Base directory for devbox-scripts (required)
# ------------------------------------------------------------------------------

set -e

READY_SCRIPT="$DEVBOX_SCRIPTS_DIR/services/postgresql/ready.sh"

if ! "$READY_SCRIPT" 2>/dev/null; then
  rm -rf "$PGDATA"
  echo "PostgreSQL data successfully cleaned"
else
  echo "PostgreSQL is running. Service must be stopped before you can clean the data."
  exit 1
fi
