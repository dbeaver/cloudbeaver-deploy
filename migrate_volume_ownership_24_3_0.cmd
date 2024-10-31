@echo off
setlocal

set SERVICE_NAME=cloudbeaver
set VOLUME_PATH=/opt/cloudbeaver/workspace
set NEW_USER=dbeaver
set NEW_GROUP=dbeaver

echo Starting service '%SERVICE_NAME%'...
docker compose up -d %SERVICE_NAME%

set CONTAINER_NAME=
:wait_for_container
for /f "delims=" %%i in ('docker ps --filter "name=%SERVICE_NAME%" --format "{{.Names}}"') do set CONTAINER_NAME=%%i
if "%CONTAINER_NAME%"=="" (
  echo Waiting for container associated with service '%SERVICE_NAME%' to start...
  timeout /t 1 >nul
  goto :wait_for_container
)

echo Container '%CONTAINER_NAME%' is up and running.

docker exec -it %CONTAINER_NAME% bash -c "id '%NEW_USER%' &>/dev/null || { useradd -m -s /bin/bash '%NEW_USER%' && echo 'Created user: %NEW_USER%'; }"

docker exec -it %CONTAINER_NAME% chown -R %NEW_USER%:%NEW_GROUP% %VOLUME_PATH%

docker exec -it %CONTAINER_NAME% bash -c "find '%VOLUME_PATH%' -type d -exec chmod 775 {} +"
docker exec -it %CONTAINER_NAME% bash -c "find '%VOLUME_PATH%' -type f -exec chmod 664 {} +"

echo Volume migration completed successfully.

docker compose down %SERVICE_NAME%

endlocal
