# CloudBeaver Enterprise deployment

### Version 25.1

CloudBeaver Enterprise is a client-server application.
It requires server deployment. You can deploy it on a single host (e.g. your local computer) or in a cloud.

## Installation with Docker Compose

It is the simplest way to install [CloudBeaver Enterprise Edition](https://dbeaver.com/cloudbeaver-enterprise/).  
All you need is a Linux, macOS, or Windows machine with Docker.

CloudBeaver can be run in a [single docker container](https://dbeaver.com/docs/cloudbeaver/CloudBeaver-Enterprise-deployment-from-docker-image/).  
However you can use Docker compose for easy web server (HTTPS) configuration.

### System requirements
- Minimum 4GB RAM
- Minimum 50GB storage, > 100GB recommended
- Ubuntu recommended
- [Docker](https://docs.docker.com/engine/install/ubuntu/) installed. Make sure you have chosen the right OS distro.
- [docker-compose](https://docs.docker.com/compose/install/) binary installed and added to your PATH variable. Supported versions 2.10 and above
    - If you install `docker-compose-plugin`, you must use the `docker compose` command instead of `docker-compose`.

### User and permissions changes

Starting from CloudBeaver v25.0 process inside the container now runs as the ‘dbeaver’ user (‘UID=8978’), instead of ‘root’.  
If a user with ‘UID=8978’ already exists in your environment, permission conflicts may occur.  
Additionally, the default Docker volumes directory’s ownership has changed.  
Previously, the volumes were owned by the ‘root’ user, but now they are owned by the ‘dbeaver’ user (‘UID=8978’).  

### Upgrade from version ≤ 24.3.0 to 25.2.0+ (volume-ownership migration)  

If you are on ≤ 24.3.0, **do not** jump directly to 25.2.0 or later.  
First upgrade to 25.1.0, let the stack start once, then upgrade to your desired 25.x.0 tag.  

**Reason:**  
25.1.0 still starts as `root` and automatically chowns every files in the volumes to ‘dbeaver’ user (‘UID=8978’).  
From 25.2.0 onward the container itself runs only as `dbeaver`, so the volumes must already belong to that UID/GID.  

### Bind-volume configuration

**Use this section only if you want to replace Docker-managed volumes with host-side bind mounts.** 

Since the container now runs as a non-root user, any host directory mountedread-write must be owned by that same UID/GID.
Using the steps above guarantees seamless file-system access while retaining a secure permission scheme on the host.

1. Create the folders and set ownership

CloudBeaver containers (v25.2.0+) run as the `dbeaver` user (UID 8978, GID 8978).  
Any host directory that is mounted read-write must therefore be owned by the same UID/GID.

```
# Create the directories (replace the paths with ones that suit your host)
sudo mkdir -p -m 750 \
  /var/dbeaver/cloudbeaver/workspace        \
  /var/dbeaver/cloudbeaver/certificates     \
  /var/dbeaver/cloudbeaver/custom           \
  /var/dbeaver/cloudbeaver/keys

# Give them to the container’s user and group (UID=8978, GID=8978)
sudo chown -R 8978:8978 \
  /var/dbeaver/cloudbeaver/workspace        \
  /var/dbeaver/cloudbeaver/certificates     \
  /var/dbeaver/cloudbeaver/custom           \
  /var/dbeaver/cloudbeaver/keys

```

2. Reference the host folders in docker-compose.yml

Replace each named volume you want to turn into a bind mount using the following template:

```
volumes:
  <compose-volume-name>:
    driver: local
    driver_opts:
      type: none
      o: bind
      device: /var/dbeaver/cloudbeaver/<matching-folder>
```

### Configuring proxy server (Nginx / HAProxy)

Starting from v25.1, CloudBeaver supports two types of proxy servers: Nginx and HAProxy. You can choose your preferred proxy type by setting the following variable in the .env file:

`PROXY_TYPE=nginx` # Available options: nginx, haproxy

The default value is `nginx`. Switching between proxy types is seamless: configuration files and SSL certificates are retained due to shared Docker volumes.  
However, note that the container name has changed from `nginx` to `web-proxy`.

#### Proxy listen ports

When using Docker Compose with host networking mode (network_mode: host), you may configure proxy ports using these environment variables:
```
LISTEN_PORT_HTTP=80
LISTEN_PORT_HTTPS=443
```
These variables specify which ports the proxy listens to inside the container.

#### Notes for Nginx users

If you use Nginx as your proxy server and customize the `COMPOSE_PROJECT_NAME` in your .env file, make sure to pass this variable explicitly to the container environment:
```
environment:
  - COMPOSE_PROJECT_NAME=${COMPOSE_PROJECT_NAME}
```
This step is only required for Nginx, as HAProxy resolves service names via Docker DNS automatically.

### Configuring and starting the CloudBeaver cluster
1. Clone repository
   ```sh
   git clone https://github.com/dbeaver/cloudbeaver-deploy
   ```
2. Open the configuration file
    - Navigate to `cloudbeaver-deploy`
    - Copy `.env.example` to `.env`
    - Edit the `.env` file to set configuration properties
    - It is highly recommended to change the default database password in `CLOUDBEAVER_DB_PASSWORD` variable
3. Start the cluster
    - `docker-compose up -d` or `docker compose up -d`
4. Ensure the following TCP ports are available in your network stack
    - 80/tcp
    - 443/tcp (for HTTPS access)
5. Open `https://<deployment-machine-ip-address>` to access the app. This URL will open the admin panel when the app is first started.

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
- [25.0.0](https://github.com/dbeaver/cloudbeaver-deploy/tree/25.0.0)
- [24.3.0](https://github.com/dbeaver/cloudbeaver-deploy/tree/24.3.0)
- [24.2.0](https://github.com/dbeaver/cloudbeaver-deploy/tree/24.2.0)
- [24.1.0](https://github.com/dbeaver/cloudbeaver-deploy/tree/24.1.0)