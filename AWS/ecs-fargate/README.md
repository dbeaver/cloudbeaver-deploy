### Cloudbeaver deployment for AWS ECS and Fargate with Terraform.

1. First you need to install and configure your AWS CLI:

   - [Install AWS CLI](https://docs.aws.amazon.com/cli/v1/userguide/cli-chap-install.html)

   - [Environment variables to configure the AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-envvars.html)

2. Next you need to [install Terraform](https://developer.hashicorp.com/terraform/install)

3. Configuration your cluster database:

 **Note:** only [Amazon RDS for PostgreSQL](https://aws.amazon.com/rds/postgresql/) is supported.
      - Open `variables.tf`.
      - Specify `rds_db_version`, the default is `postgres:16.1`. Only PostgreSQL version can be specified.
      - Update the credentials for database in `cloudbeaver-db-env`.

4. Configure the deployment in `variables.tf` file as follows:  
   - Set your `aws_account_id`, you can get it by logging into your AWS console:

   ![alt text](images/image.png)

   - Set your `aws_region` in format `us-east-1`. For example:

   ![alt text](images/image-1.png)

   - Ensure that the `alb_certificate_Identifier` variable contains the ID from [AWS Certificate Manager](#importing-an-ssl-certificate-in-aws) corresponding to your domain specified in `CLOUDBEAVER_PUBLIC_URL`.
   - You can customize the deployment version by updating the `cloudbeaver_version` environment variable. The default version is `24.1.0`.

5. Target cluster configuration for deployment:
   By default deployment created AWS ECS Cluster, and make deployment in them.
   If you want make deployment in your existed cluster follow steps:
      - Open `variables.tf`.
      - Change variable `create_cluster` to `false`
      - Set `existed_cluster_id` as your ECS cluster name, wich existed in your region.

6. Run `terraform init` and then `terraform apply` in `ecs-fargate` directory to create the ECS cluster and complete the deployment.

7. Cluster destruction is performed in reverse order:
    - Run `terraform destroy` in `ecs-fargate` directory to destroy ECS cluster.

### Importing an SSL Certificate in AWS

   1. Open your web browser and log in to the AWS (Amazon Web Services) Console.  

   2. Navigate to the `AWS Certificate Manager` service.  

   3. Click on the `Import` button and fill in the necessary certificate details as prompted.  

   After completing these steps, you will receive an Identifier for your newly imported certificate.

### Version update

1. Navigate to the `cloudbeaver-deploy/AWS/ecs-fargate` directory.

2. Specify the desired version in  `variables.tf` in the `cloudbeaver_version` variable.

3. Run `terraform apply` to upgrade the ECS cluster and complete the deployment.
