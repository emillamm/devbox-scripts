#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: ready.sh (PostgreSQL)
#
# Description:
#   Checks if PostgreSQL is ready to accept connections.
#
# Environment:
#   PGHOST         - PostgreSQL socket directory (required)
#   POSTGRES_USER  - PostgreSQL user (required)
#   POSTGRES_PORT  - PostgreSQL port (required)
# ------------------------------------------------------------------------------

set -e

pg_isready -q -h "$PGHOST" -U "$POSTGRES_USER" -p "$POSTGRES_PORT"
