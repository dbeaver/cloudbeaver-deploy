#!/bin/bash

CONTAINER_NAME=$(docker ps --filter "name=cloudbeaver" --format "{{.Names}}")
VOLUME_PATH="/opt/cloudbeaver/workspace"
NEW_USER="dbeaver"
NEW_GROUP="dbeaver"

if [ -z "$CONTAINER_NAME" ]; then
  echo "Error: No container found with the name 'cloudbeaver'"
  exit 1
fi

docker exec -it "$CONTAINER_NAME" bash -c "
  id '$NEW_USER' &>/dev/null || { useradd -m -s /bin/bash '$NEW_USER' && echo 'Created user: $NEW_USER'; }
  chown -R '$NEW_USER':'$NEW_GROUP' '$VOLUME_PATH'
  find '$VOLUME_PATH' -type d -exec chmod 775 {} +
  find '$VOLUME_PATH' -type f -exec chmod 664 {} +
  chmod 775 '$VOLUME_PATH/g_GlobalConfiguration' '$VOLUME_PATH/GlobalConfiguration'
"

echo "Volume migration completed successfully."
