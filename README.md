# CloudBeaver Enterprise deployment

### Version 24.2

CloudBeaver Enterprise is a client-server application.
It requires server deployment. You can deploy it on a single host (e.g. your local computer) or in a cloud.

## Installation with Docker Compose

It is the simplest way to install [CloudBeaver Enterprise Edition](https://dbeaver.com/cloudbeaver-enterprise/).  
All you need is a Linux, macOS, or Windows machine with Docker.

CloudBeaver can be run in a [single docker container](https://dbeaver.com/docs/cloudbeaver/CloudBeaver-Enterprise-deployment-from-docker-image/).  
However you can use Docker compose for additional product features such as:
- Load balancing
- Easy web server (HTTPS) configuration

### System requirements
- Minimum 4GB RAM
- Minimum 50GB storage, > 100GB recommended
- Ubuntu recommended
- [Docker](https://docs.docker.com/engine/install/ubuntu/) installed. Make sure you have chosen the right OS distro.
- [docker-compose](https://docs.docker.com/compose/install/) binary installed and added to your PATH variable. Supported versions 2.10 and above
    - If you install `docker-compose-plugin`, you must use the `docker compose` command instead of `docker-compose`.

### Configuring and starting the CloudBeaver cluster
1. Clone repository
   ```sh
   git clone https://github.com/dbeaver/cloudbeaver-deploy
   ```
1. Open the configuration file
    - Edit the `.env` file to set configuration properties
    - It is highly recommended to change the default database password in `CLOUDBEAVER_DB_PASSWORD` variable
1. Start the cluster
    - `docker-compose up -d` or `docker compose up -d`
1. Ensure the following TCP ports are available in your network stack
    - 80/tcp
    - 443/tcp (for HTTPS access)
1. Open `http://<deployment-machine-ip-address>` to access the app. This URL will open the admin panel when the app is first started.

### Stopping the cluster
`docker-compose down`

### Configuring SSL (HTTPS)

There are two ways to configure SSL:
1. You can configure HTTPS automatically in the admin panel.   
   In this case your server domain address will be `<deployment-domain>.<organization-domain>.databases.team`.   
   You can setup organization and deployment domains.
2. You can issue you own SSL cenrtificate and configure it manually by editing nginx config.

### Podman requirements

as user `root` run following commands before [Configuring and starting the CloudBeaver cluster](#configuring-and-starting-team-edition-cluster):
1. ```loginctl enable-linger 1000```
2. ```echo 'net.ipv4.ip_unprivileged_port_start=80' >> /etc/sysctl.conf```
3. ```sysctl -p```

on step 4 of [Configuring and starting the CloudBeaver cluster](#configuring-and-starting-team-edition-cluster) use `podman-compose` tool intead of `docker-compose` and on step 4 define compose file name:
```
podman-compose -f podman-compose.yml up -d
```
or replace `docker-compose.yml` with `podman-compose.yml` and use `podman-compose` without compose project definition

### Updating the cluster
1. Replace the value of `CLOUDBEAVER_VERSION_TAG` in `.env` with a preferred version. If you use the tag `latest`, you don't need to do anything during this step.
2. Pull new docker images: `docker-compose pull` or `docker compose pull`
3. Restart the cluster: `docker-compose up -d` or `docker compose up -d`

### Older versions:
- [24.1.0](https://github.com/dbeaver/cloudbeaver-deploy/tree/24.1.0)