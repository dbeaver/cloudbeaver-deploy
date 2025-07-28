# CloudBeaver Enterprise Edition - AWS EKS Deployment

## Prerequisites

- [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed and configured
- [eksctl](https://eksctl.io/installation/) installed  
- [Helm](https://helm.sh/docs/intro/install/) installed
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) installed
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) installed
- Access to an existing **EKS cluster**

Policy required:
- [AmazonElasticFileSystemFullAccess](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonElasticFileSystemFullAccess.html)

## AWS volumes configuration for Kubernetes deployment

To store CloudBeaver EE data in the cloud, you need to configure cloud volumes. For example, you can store connection configurations and user information in AWS EFS.

### Step 1: Associate IAM OIDC Provider

Associate the IAM OIDC provider with your EKS cluster to enable IAM roles for service accounts.

```bash
eksctl utils associate-iam-oidc-provider \
  --region=<your-region> \
  --cluster=<your-cluster-name> \
  --approve
```

### Step 2: Install AWS EFS and EBS CSI Drivers

Install the AWS EFS and EBS CSI drivers using Helm.

```bash
helm repo add aws-efs-csi-driver https://kubernetes-sigs.github.io/aws-efs-csi-driver/
helm repo add aws-ebs-csi-driver https://kubernetes-sigs.github.io/aws-ebs-csi-driver/
helm repo update

helm install aws-efs-csi-driver aws-efs-csi-driver/aws-efs-csi-driver --namespace kube-system
helm install aws-ebs-csi-driver aws-ebs-csi-driver/aws-ebs-csi-driver --namespace kube-system
```

### Step 3: Configure EFS via Terraform

1. Navigate to directory `cloudbeaver-deploy/AWS/aws-eks`
2. Open the `main.tf` file in a text editor.
3. Update the following variables with your AWS region and EKS cluster name:
```
variable "region" {
  description = "Region for AWS EFS"
  default     = "<your-region>"
}
variable "cluster_name" {
  description = "EKS cluster name"
  default     = "<your-cluster-name>"
}
```
4. Run `terraform init`.
5. Next, run `terraform apply`, which will output `efs_file_system_id`.
6. Open the file `cloudbeaver-deploy/k8s/values.yaml` and update the `fileSystemId` parameter with the value of `efs_file_system_id` obtained in the previous step.
7. Fill in the other parameters as shown in the example:

```yaml
cloudProvider: aws
storage:
  type: efs
  storageClassName: "efs-sc"
  efs:
    fileSystemId: "<your-efs-id>"
```

Once this is set up, you can deploy CloudBeaver EE by following [this guide](../../k8s/README.md).

## AWS ALB configuration for Kubernetes deployment

This deployment option can use Nginx, HAProxy, or AWS ALB as an ingress controller. If you want to use [AWS Application Load Balancer](https://docs.aws.amazon.com/elasticloadbalancing/latest/application/introduction.html), follow the steps below.

Install `AWS CLI`: If `AWS CLI` is not installed yet, install it by following the instructions on the [official AWS CLI website](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html).  

Install `eksctl`: `eksctl` is a command-line utility for creating and managing EKS clusters. Install eksctl by following the instructions on the [official eksctl website](https://eksctl.io/installation/).  

Policy required for eksctl to work:

- [CloudFormation Full Access](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AWSCloudFormationFullAccess.html)
- [EKS Full Access](https://docs.aws.amazon.com/eks/latest/userguide/security_iam_id-based-policy-examples.html#security_iam_id-based-policy-examples-console)
- [EC2 and EC2 Auto Scaling Full Access](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/AmazonEC2FullAccess.html)
- [IAM Full Access](https://docs.aws.amazon.com/aws-managed-policy/latest/reference/IAMFullAccess.html)
- [Systems Manager](https://docs.aws.amazon.com/systems-manager/latest/userGuide/security_iam_id-based-policy-examples.html)

1. OIDC Provider Association:  

```bash
eksctl utils associate-iam-oidc-provider --region=<your-region> --cluster=<your-cluster-name> --approve
```

2. Create IAM role and link policy:  

Create policy IAM:  
```bash
curl -o iam_policy.json https://raw.githubusercontent.com/kubernetes-sigs/aws-load-balancer-controller/main/docs/install/iam_policy.json
aws iam create-policy --policy-name AWSLoadBalancerControllerIAMPolicy --policy-document file://iam_policy.json
```

Create IAM role and link policy:  
```bash
eksctl create iamserviceaccount \
  --cluster <your-cluster-name> \
  --region <your-region> \
  --namespace kube-system \
  --name aws-load-balancer-controller \
  --attach-policy-arn arn:aws:iam::<your-account-id>:policy/AWSLoadBalancerControllerIAMPolicy \
  --approve
```

3. Install AWS Load Balancer Controller using Helm:  

```bash
helm repo add eks https://aws.github.io/eks-charts
helm repo update

helm install aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=<your-cluster-name> \
  --set serviceAccount.create=false \
  --set region=<your-region> \
  --set vpcId=<your-vpc-id> \
  --set serviceAccount.name=aws-load-balancer-controller
```

Once this is set up, you can deploy CloudBeaver EE by following [this guide](../../k8s/README.md). 