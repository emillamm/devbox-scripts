#!/usr/bin/env bash
# ------------------------------------------------------------------------------
# Script: init.sh (PostgreSQL)
#
# Description:
#   Initializes PostgreSQL data directory and creates the database.
#   Skips initialization if already done.
#
# Environment:
#   PGDATA            - PostgreSQL data directory (required)
#   PGHOST            - PostgreSQL socket directory (required)
#   POSTGRES_USER     - PostgreSQL user (required)
#   POSTGRES_PORT     - PostgreSQL port (required)
#   POSTGRES_DATABASE - Database name to create (required)
#   DEVBOX_SCRIPTS_DIR - Base directory for devbox-scripts (required)
# ------------------------------------------------------------------------------

set -e

# Check if database is already initialized
if [ -f "$PGDATA/PG_VERSION" ]; then
  exit 0
fi

echo "Initializing PostgreSQL data directory..."
initdb -D "$PGDATA" -U "$POSTGRES_USER"

# Start service
"$DEVBOX_SCRIPTS_DIR/manage-service.sh" start postgresql

# Create primary database
if ! psql -d postgres -U "$POSTGRES_USER" -p "$POSTGRES_PORT" -Atqc "SELECT 1 FROM pg_database WHERE datname = '$POSTGRES_DATABASE'" | grep -q 1; then
  createdb "$POSTGRES_DATABASE" -h "$PGHOST" -U "$POSTGRES_USER" -p "$POSTGRES_PORT"
fi

# Stop service
"$DEVBOX_SCRIPTS_DIR/manage-service.sh" stop postgresql
