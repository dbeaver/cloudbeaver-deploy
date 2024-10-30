@echo off
setlocal

set CONTAINER_NAME=
for /f "delims=" %%i in ('docker ps --filter "name=cloudbeaver" --format "{{.Names}}"') do set CONTAINER_NAME=%%i

set VOLUME_PATH=/opt/cloudbeaver/workspace
set NEW_USER=dbeaver
set NEW_GROUP=dbeaver

if "%CONTAINER_NAME%"=="" (
  echo Error: No container found with the name 'cloudbeaver'
  exit /b 1
)

docker exec -it %CONTAINER_NAME% bash -c "if ! id \"%NEW_USER%\" &>/dev/null; then useradd -m -s /bin/bash \"%NEW_USER%\" && echo \"Created user: %NEW_USER%\"; fi"

docker exec -it %CONTAINER_NAME% chown -R %NEW_USER%:%NEW_GROUP% %VOLUME_PATH%

docker exec -it %CONTAINER_NAME% find %VOLUME_PATH% -type d -exec chmod 775 {} \;
docker exec -it %CONTAINER_NAME% find %VOLUME_PATH% -type f -exec chmod 664 {} \;

docker exec -it %CONTAINER_NAME% chmod 775 %VOLUME_PATH%/g_GlobalConfiguration
docker exec -it %CONTAINER_NAME% chmod 775 %VOLUME_PATH%/GlobalConfiguration

echo Volume migration completed successfully.
endlocal
