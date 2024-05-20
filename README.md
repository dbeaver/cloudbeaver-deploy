# CloudBeaver Enterprise Installation with Docker Compose

It is the simplest way to install CloudBeaver Enterprise Edition.  
All you need is a Linux, macOS, or Windows machine with Docker.

### System requirements
- Minimum 4GB RAM
- Minimum 50GB storage, > 100GB recommended
- Ubuntu recommended
- [Docker](https://docs.docker.com/engine/install/ubuntu/) installed. Make sure you have chosen the right OS distro.
- [docker-compose](https://docs.docker.com/compose/install/) binary installed and added to your PATH variable. Supported versions 2.10 and above
    - If you install `docker-compose-plugin`, you must use the `docker compose` command instead of `docker-compose`.

### Configuring and starting the CloudBeaver cluster
1. Ensure the following TCP ports are available in your network stack
   - 80/tcp
   - 443/tcp (for HTTPS access)
1. Open the configuration file
    - Edit the `.env` file to set configuration properties
1. Start the cluster
   - `docker-compose up -d` or `docker compose up -d`

Open __CLOUDBEAVER_SCHEME__://__CLOUDBEAVER_DOMAIN__ to access the app. This URL will open the admin panel when the app is first started.

### Stopping the cluster
`docker-compose down`

### Updating the cluster
1. Replace the value of `CLOUDBEAVER_VERSION_TAG` in `.env` with a preferred version. If you use the tag `latest`, you don't need to do anything during this step.
2. Pull new docker images: `docker-compose pull` or `docker compose pull`  
3. Restart the cluster: `docker-compose up -d` or `docker compose up -d`
