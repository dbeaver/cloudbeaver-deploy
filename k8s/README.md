## Cloudbeaver Helm chart for Kubernetes

#### Minimum requirements:

* Kubernetes >= 1.23
* 2 CPUs
* 4Gb RAM
* Linux or macOS as deploy host
* `git` and `kubectl` installed

[//]: # (* [Nginx load balancer]&#40;https://docs.nginx.com/nginx-ingress-controller/installation/installation-with-helm/&#41; and [Kubernetes Helm plugin]&#40;https://helm.sh/docs/topics/plugins/&#41; added to your `k8s`)

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
- Configure domain and SSL certificate (optional)
  - Add an A record in your DNS hosting for a value of `cloudbeaverBaseDomain` variable with load balancer IP address.
  - If you set the *HTTPS* endpoint scheme, then create a valid TLS certificate for the domain endpoint `cloudbeaverBaseDomain` and place it into `k8s/ingressSsl`:  
    Certificate: `ingressSsl/fullchain.pem`  
    Private Key: `ingressSsl/privkey.pem`
- Deploy Cloudbeaver with Helm: `helm install cloudbeaver ./ --values ./values.yaml`

### Version update procedure.

- Change directory to `cloudbeaver-deploy/k8s`.
- Change value of `imageTag` in configuration file `values.yaml` with a preferred version. Go to next step if tag `latest` set.
- Upgrade cluster: `helm upgrade cloudbeaver ./ --values ./values.yaml` 

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
