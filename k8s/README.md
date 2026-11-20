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

1. Change directory to `cloudbeaver-deploy/k8s`.
2. Update your deployment files:
   - Fetch the latest changes: `git fetch`.
   - Switch to the branch for the version you're updating to: `git checkout <version>` (for example, `git checkout 26.2.0`).
3. Change the value of `imageTag` in the `values.yaml` configuration file to the preferred version. Skip this step if the tag is set to `latest`.
4. Upgrade the cluster: `helm upgrade cloudbeaver ./ --values ./values.yaml`.

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

For a managed DigitalOcean load balancer, enable PROXY protocol on both the load balancer and ingress controller. These settings do not apply to k3s ServiceLB (Klipper).

In the ingress controller Service annotations:

- `service.beta.kubernetes.io/do-loadbalancer-enable-proxy-protocol: "true"`
- `service.beta.kubernetes.io/do-loadbalancer-hostname: "cloudbeaverBaseDomain"`

For community ingress-nginx, also set `use-proxy-protocol: "true"` in its controller ConfigMap and restrict `proxy-real-ip-cidr` to the trusted load balancer source ranges. Coordinate both changes to avoid interrupting traffic.

### Real client IP

The example values disable forwarded-header processing (`forwardProxy: false`). After restricting backend access to trusted proxies and sanitizing incoming headers as described below, opt in through chart values:

```yaml
forwardProxy: true
ingressAnnotations: {}
```

`forwardProxy` sets `CLOUDBEAVER_APP_FORWARD_PROXY` on CloudBeaver. Set it to `false` to disable forwarded-header processing. Omitting it preserves the image/configuration default; old values files keep their previous behavior.

`ingressAnnotations` adds or overrides annotations for the selected controller without duplicate keys. For ALB, precedence is built-in annotations, then `aws.annotations`, then `ingressAnnotations`. For example:

```yaml
ingressController: alb
ingressAnnotations:
  alb.ingress.kubernetes.io/load-balancer-attributes: "idle_timeout.timeout_seconds=600,routing.http.xff_header_processing.mode=append"
```

The chart configures the application and its Ingress, not an external ingress controller or its Service. Configure that upstream separately:

| Traffic path | Required upstream configuration |
| --- | --- |
| k3s ServiceLB or source-preserving L4 LB → ingress | Preserve source IP; use `externalTrafficPolicy: Local` on the ingress controller's external Service where needed. Send traffic only to nodes with ready local ingress endpoints. |
| ALB → application | Forward `X-Forwarded-For` (ALB defaults to append mode). `externalTrafficPolicy: Local` does not recover the client IP from ALB connections. |
| ALB / trusted HTTP proxy → ingress | Configure ingress to use forwarded headers only from trusted upstream ranges. For community ingress-nginx, review `use-forwarded-headers`, `enable-real-ip`, and `proxy-real-ip-cidr`. |
| NLB → ingress | For instance targets, preserve source IP and avoid Service SNAT (usually `Local`). For IP targets, check `preserve_client_ip.enabled` and network support. Alternatively, enable PROXY protocol v2 on both NLB and ingress. |

**Trust boundary:** enable `forwardProxy` only when backend access is restricted to trusted proxies (network policy/firewall/security groups). The chart does not enforce this restriction. The first trusted HTTP proxy must remove client-supplied `Forwarded` and `X-Forwarded-*` headers and construct authoritative values; subsequent proxies must trust only known upstreams. ALB append mode alone does not sanitize a forged leading `X-Forwarded-For` entry: use a sanitizing trusted edge if clients can supply these headers. Never trust arbitrary source CIDRs. If the upstream has already lost the IP without forwarding it, the chart cannot recover it.

After deployment, make a fresh request/session and compare the expected public client IP with ingress access logs and application audit/session records (QM where available). A node/pod address indicates source-IP loss upstream. Also verify that forged forwarded headers do not change the recorded IP and that direct backend access is blocked.
