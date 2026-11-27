## Cloudbeaver Helm chart for Kubernetes

#### Minimum requirements:

* Kubernetes >= 1.23
* 2 CPUs
* 4Gb RAM
* Linux or macOS as deploy host
* `git` and `kubectl` installed
* [Nginx load balancer](https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/) and [Kubernetes Helm plugin](https://helm.sh/docs/topics/plugins/) added to your `k8s`

#### Supported Ingress Controllers:

* **nginx** - NGINX Ingress Controller (default)
* **haproxy** - HAProxy Ingress Controller  
* **alb** - AWS Application Load Balancer (for AWS EKS)

For AWS EKS specific deployment instructions, see [AWS EKS deployment guide](../AWS/aws-eks/README.md).


### User and permissions changes

Starting from CloudBeaver v25.0 process inside the container now runs as the ‘dbeaver’ user (‘UID=8978’), instead of ‘root’.  
If a user with ‘UID=8978’ already exists in your environment, permission conflicts may occur.  
Additionally, the default Docker volumes directory’s ownership has changed.  
Previously, the volumes were owned by the ‘root’ user, but now they are owned by the ‘dbeaver’ user (‘UID=8978’).  

### How to run services
- Clone this repo from GitHub: `git clone https://github.com/dbeaver/cloudbeaver-deploy`
- `cd cloudbeaver-deploy/k8s`
- `cp ./values.yaml.example ./values.yaml`
- Edit chart values in `values.yaml` (use any text editor)
- You must set the `cloudbeaver_db_password` variable before deploying the cluster. The database password is empty by default and the deployment will fail without it.
- Configure domain and SSL certificate (optional)
  - Add an A record in your DNS hosting for a value of `cloudbeaverBaseDomain` variable with load balancer IP address.
  - If you set the *HTTPS* endpoint scheme, then create a valid TLS certificate for the domain endpoint `cloudbeaverBaseDomain` and place it into `k8s/ingressSsl`:  
    Certificate: `ingressSsl/fullchain.pem`  
    Private Key: `ingressSsl/privkey.pem`
- Deploy Cloudbeaver with Helm: `helm install cloudbeaver ./ --values ./values.yaml`

### Version update procedure

Keep your existing `values.yaml` and database PVC. Do not copy the new `values.yaml.example` over it. The example selects PostgreSQL 18 for new installations; a chart without `postgres.image` keeps PostgreSQL 13. Changing the image does not migrate an existing database.

1. Change directory to `cloudbeaver-deploy/k8s`.
2. Update your deployment files:
   - Fetch the latest changes: `git fetch`.
   - Switch to the deployment branch or exact Git tag, for example `git checkout 26.3.0`.
3. For stable releases starting with 26.3, set `cloudbeaver.imageTag` to `"26.3"` in `values.yaml` to follow that release line, or use a full tag such as `"26.3.0.1"` to pin an exact release. `26.3` is an image tag, not a Git ref. Set `cloudbeaver.pullPolicy` to `Always` for a rolling tag. Keep `ea` for Early Access.
4. Upgrade the cluster: `helm upgrade cloudbeaver ./ --values ./values.yaml`.

Run the Helm upgrade even if the rolling tag hasn’t changed. The chart replaces the CloudBeaver pods so they pull the current image.

### OpenShift deployment

You need additional configuration changes

- In `values.yaml` change the `ingressController` value to `haproxy`
- Add security context  
  Uncomment the following lines in `cloudbeaver.yaml` files in [templates/deployment](templates/deployment):
    ```yaml
          # securityContext:
          #     runAsUser: 1000
          #     runAsGroup: 1000
          #     fsGroup: 1000
          #     fsGroupChangePolicy: "Always"
    ```

### Digital Ocean proxy configuration

Edit ingress controller with:

- `kubectl edit service -n ingress-nginx ingress-nginx-controller`

and add two lines in the `metadata.annotations`

- `service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol: "true"`
- `service.beta.kubernetes.io/do-loadbalancer-hostname: "cloudbeaverBaseDomain"`
