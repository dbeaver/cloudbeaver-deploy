# CloudBeaver Enterprise Installation with Docker Compose

It is the simplest way to install CloudBeaver Enterprise Edition.  
All you need is a Linux, MacOs or Windows machine with docker.

### System requirements

- Minimum 4GB RAM
- Minimum 50GB storage, > 100GB recommended
- Ubuntu recommended
- [Docker](https://docs.docker.com/engine/install/ubuntu/) installed. Make sure you have chosen the right OS distro.
- [docker-compose](https://docs.docker.com/compose/install/) binary installed and added to your PATH variable. Supported versions 2.10 and above
    - If you install `docker-compose-plugin`, you must use the `docker compose` command instead of `docker-compose`.

Ensure all TCP ports from the below list are available in your network stack.
 - 80/tcp
 - 443/tcp (for HTTPS access)

### Using external DB

By default, Team Edition stores all data in an internal PostgreSQL database. If you want to use it, skip this step.

If you want to use another database on your side, you can do it according to these instructions.

1. Go to the `compose/cbte` folder, and open `.env.example` file.
2. Change `USE_EXTERNAL_DB` to `true` value.
3. Change `CLOUDBEAVER_DB_DRIVER` to driver for a database you want to use, for example: `postgres-jdbc`/`mysql8`/`oracle_thin`
4. Enter the authentication data for your database in the fields `CLOUDBEAVER_DB_URL` `CLOUDBEAVER_DB_USER` `CLOUDBEAVER_DB_PASSWORD`


### Configuring and starting CloudBeaver cluster

1. Open configuration file
    - Edit `.env` file to set configuration properties
2. Start the cluster
   - `docker-compose up -d` or `docker compose up -d`

### Services will be accessible in the next URIs

- https://__CLOUDBEAVER_DOMAIN__ - web interface. It will open the admin panel on the first start
- https://__CLOUDBEAVER_DOMAIN__/dc - endpoint for desktop applications

### Stopping the cluster
`docker-compose down`

### Version update procedure

1. Change value of `CLOUDBEAVER_VERSION_TAG` in `.env` with a preferred version. Go to next step if tag `latest` is set.
2. Pull new docker images: `docker-compose pull` or `docker compose pull`  
3. Restart cluster: `docker-compose up -d` or `docker compose up -d`
