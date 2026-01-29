# devbox-scripts

Reusable service management scripts for Devbox-based projects.

## Overview

This repository provides standardized scripts for managing services (PostgreSQL, Kafka, etc.) in Devbox environments. It uses reference counting to safely share services across multiple processes.

## Installation

Add to your project's `devbox.json` shell init:

```json
{
  "shell": {
    "init_hook": [
      "export DEVBOX_SCRIPTS_DIR=\"${DEVBOX_SCRIPTS_DIR:-$DEVBOX_PROJECT_ROOT/../devbox-scripts}\"",
      "[ -d \"$DEVBOX_SCRIPTS_DIR\" ] || git clone git@github.com:emillamm/devbox-scripts.git \"$DEVBOX_SCRIPTS_DIR\"",
      "export PATH=\"$DEVBOX_SCRIPTS_DIR:$PATH\""
    ]
  }
}
```

Set `DEVBOX_SCRIPTS_DIR` to override the default location.

## Usage

### manage-service.sh

The main entry point for service lifecycle management:

```bash
# Start a service (increments reference count)
manage-service.sh start postgresql

# Stop a service (decrements reference count, stops when count reaches 0)
manage-service.sh stop postgresql
```

### Service Scripts

Each service directory contains:

- `ready.sh` (required) - Check if service is ready to accept connections
- `start.sh` (optional) - Start command for the service
- `init.sh` (optional) - Initialize service data/configuration
- `clean.sh` (optional) - Remove all service data

## Environment Variables

### PostgreSQL

| Variable | Description | Required |
|----------|-------------|----------|
| `PGDATA` | Data directory | Yes |
| `PGHOST` | Socket directory | Yes |
| `POSTGRES_USER` | Database user | Yes |
| `POSTGRES_PORT` | Port number | Yes |
| `POSTGRES_DATABASE` | Database name (for init) | Yes |

### Kafka

| Variable | Description | Required |
|----------|-------------|----------|
| `KAFKA_DATA_DIR` | Data directory | Yes |
| `KAFKA_CONFIG_TEMPLATE` | Path to kafka.properties template | Yes (for init) |
| `KAFKA_BOOTSTRAP_SERVER` | Bootstrap server address | No (default: localhost:29092) |
