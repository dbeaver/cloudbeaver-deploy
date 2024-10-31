#!/bin/bash

SERVICE_NAME="cloudbeaver"
VOLUME_PATH="/opt/cloudbeaver/workspace"
NEW_USER="dbeaver"
NEW_GROUP="dbeaver"

if ! [ -n "$(docker ps --filter "name=$SERVICE_NAME" --format "{{.Names}}")" ]; then
  echo "Starting service '$SERVICE_NAME'..."
  docker compose up -d "$SERVICE_NAME"
fi

CONTAINER_NAME=""
until [ -n "$CONTAINER_NAME" ]; do
  echo "Waiting for container associated with service '$SERVICE_NAME' to start..."
  CONTAINER_NAME=$(docker ps --filter "name=$SERVICE_NAME" --format "{{.Names}}")
  sleep 1
done

echo "Container '$CONTAINER_NAME' is up and running."

docker exec -it "$CONTAINER_NAME" bash -c "
  id '$NEW_USER' &>/dev/null || { useradd -m -s /bin/bash '$NEW_USER' && echo 'Created user: $NEW_USER'; }
  chown -R '$NEW_USER':'$NEW_GROUP' '$VOLUME_PATH'
  find '$VOLUME_PATH' -type d -exec chmod 775 {} +
  find '$VOLUME_PATH' -type f -exec chmod 664 {} +
  chmod 775 '$VOLUME_PATH'
"

echo "Volume migration completed successfully."

if [ -n "$(docker ps --filter "name=$SERVICE_NAME" --format "{{.Names}}")" ]; then
  echo "Stopping service '$SERVICE_NAME'..."
  docker compose down 
fi