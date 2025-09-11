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

### Upgrade from version ≤ 25.0.0 to 25.2.0+ (volume-ownership migration)  

If you are on ≤ 25.0.0, **do not** jump directly to 25.2.0 or later.  
First upgrade to 25.1.0, let the stack start once, then upgrade to your desired 25.x.0 tag.  

**Reason:**  
25.1.0 still starts as `root` and automatically chowns every files in the volumes to ‘dbeaver’ user (‘UID=8978’).  
From 25.2.0 onward the container itself runs only as `dbeaver`, so the volumes must already belong to that UID/GID.  

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

- Navigate to `cloudbeaver-deploy`
- Run command `git checkout %version%`
- Navigate to `cloudbeaver-deploy/k8s`.
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
