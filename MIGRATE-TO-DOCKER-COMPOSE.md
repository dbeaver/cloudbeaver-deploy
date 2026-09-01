# Migrating a legacy single-container deployment

Older CloudBeaver Enterprise and CloudBeaver AWS deployments may run as a single container created with `docker run`.
To migrate such a deployment to Docker Compose, copy its workspace to the volume used by the Compose deployment. The
workspace contains the server configuration and internal databases.

> **Known issue:** CloudBeaver `26.1.0` cannot migrate an H2 v1 internal database directly to PostgreSQL. If your
> workspace uses H2 v1, first start it with CloudBeaver `26.0.0` and wait for the automatic migration to complete. You
> can then update the Compose deployment to `26.1.0` or later. CloudBeaver automatically performs the intermediate H2
> v1 to H2 v2 migration and then migrates the internal data to PostgreSQL.

1. Stop the existing container and back up its workspace. These commands use the default legacy workspace path:
   ```sh
   docker stop <container_id>
   sudo tar --zstd -cf workspace.tar.zst -C /var/cloudbeaver workspace
   ```
   If the container uses a different host path for `/opt/cloudbeaver/workspace`, use that path in the following steps.
2. Clone the `26.0.0` deployment configuration and create the environment file:
   ```sh
   git clone -b 26.0.0 https://github.com/dbeaver/cloudbeaver-deploy.git
   cd cloudbeaver-deploy
   cp .env.example .env
   ```
3. For CloudBeaver AWS only, use the host-network Compose file and AWS image:
   ```sh
   printf '\nCOMPOSE_FILE=docker-compose-host.yml\n' >> .env
   sed -i 's/postgres:5432/127.0.0.1:5432/g' .env
   sed -i 's/cloudbeaver-ee/cloudbeaver-aws/g' docker-compose-host.yml
   ```
4. Set `CLOUDBEAVER_DB_PASSWORD` in `.env`.
5. Create the Compose containers and volumes, and then copy the legacy workspace to the CloudBeaver volume:
   ```sh
   docker compose create
   docker run --rm \
     -v /var/cloudbeaver/workspace:/src:ro \
     -v dbeaver_cloudbeaver:/target \
     ubuntu:24.04 cp -rp /src/. /target/
   ```
   The volume name is `<COMPOSE_PROJECT_NAME>_cloudbeaver`. The default `COMPOSE_PROJECT_NAME` is `dbeaver`.
6. Start the deployment and wait for the database migrations to finish:
   ```sh
   docker compose up -d
   docker compose logs -f cloudbeaver
   ```
7. Confirm that the server configuration, users, connections, and Query Manager history are available before updating
   to a later version.
