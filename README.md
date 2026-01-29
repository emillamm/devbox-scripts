# devbox-scripts

Reusable service management scripts for Devbox-based projects.

## Overview

This repository provides standardized scripts for managing services (PostgreSQL, Kafka, etc.) in Devbox environments. It uses reference counting to safely share services across multiple processes.

## Installation

Add as a git submodule:

```bash
git submodule add git@github.com:emillamm/devbox-scripts.git devbox-scripts
```

Then add to your `devbox.json`:

```json
{
  "env": {
    "DEVBOX_SCRIPTS_DIR": "$DEVBOX_PROJECT_ROOT/devbox-scripts"
  },
  "shell": {
    "init_hook": [
      "git submodule update --init --remote devbox-scripts",
      "source ./devbox-scripts/init.sh"
    ]
  }
}
```

## Usage

### manage-service.sh

The main entry point for service management:

```bash
manage-service.sh <action> <service>
```

Actions:
- `init` - Initialize service data/configuration
- `clean` - Remove all service data
- `start` - Start the service (with reference counting)
- `stop` - Stop the service (with reference counting)

Examples:
```bash
manage-service.sh init postgresql
manage-service.sh init kafka
manage-service.sh start postgresql
manage-service.sh stop postgresql
manage-service.sh clean postgresql
```

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

| Variable | Description | Default |
|----------|-------------|---------|
| `KAFKA_HOST` | Kafka host | `localhost` |
| `KAFKA_PORT` | Kafka broker port | `9092` |
| `KAFKA_CONTROLLER_PORT` | Kafka controller port | `9093` |
| `KAFKA_DATA_DIR` | Data directory | `$DEVBOX_PROJECT_ROOT/.devbox/kafka-data` |
| `KAFKA_CONFIG_TEMPLATE` | Path to kafka.properties template | `$DEVBOX_PROJECT_ROOT/kafka.properties` |

The template file should use these placeholders: `__KAFKA_HOST__`, `__KAFKA_PORT__`, `__KAFKA_CONTROLLER_PORT__`, `__KAFKA_DATA_DIR__`
