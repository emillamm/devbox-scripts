#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: start.sh (PostgreSQL)
#
# Description:
#   Starts the PostgreSQL server.
#
# Environment:
#   PGHOST        - PostgreSQL socket directory (required)
#   POSTGRES_PORT - PostgreSQL port (required)
# ------------------------------------------------------------------------------

set -e

exec pg_ctl start -o "-k \"$PGHOST\" -p \"$POSTGRES_PORT\""
