#!/bin/bash

# Compose-Projektpfad
COMPOSE_DIR="/home/ahmet/Projekte/superset"
COMPOSE_FILE="$COMPOSE_DIR/docker-compose.yml"

# Dienste, die überwacht werden sollen
SERVICE_NAMES=( "superset_worker" "redis" "superset_app")

UNHEALTHY_FOUND=0

for SERVICE_NAME in "${SERVICE_NAMES[@]}"; do
    STATUS=$(docker inspect --format='{{.State.Health.Status}}' "$SERVICE_NAME" 2>/dev/null)

    # Falls Container nicht existiert oder keinen Healthcheck hat
    if [[ -z "$STATUS" ]]; then
        echo "$(date): $SERVICE_NAME liefert keinen Health-Status."
        continue
    fi

    echo "$(date): $SERVICE_NAME Status: $STATUS"

    if [[ "$STATUS" == "unhealthy" ]]; then
        UNHEALTHY_FOUND=1
    fi
done

if [[ $UNHEALTHY_FOUND -eq 1 ]]; then
    echo "$(date): Mindestens ein Service ist UNHEALTHY – Neustart des gesamten Stacks..."
    docker compose -f "$COMPOSE_FILE" restart
else
    echo "$(date): Alle Services sind healthy."
fi
