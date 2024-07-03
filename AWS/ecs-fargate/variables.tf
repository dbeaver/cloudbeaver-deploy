variable "aws_account_id" {
  description = "Your AWS account ID"
  type = string
  default = ""
}

variable "aws_region" {
  description = "Region where you plan to deploy"
  type    = string
  default = ""
}

variable "create_cluster" {
  description = "Choose create cluster or use an existing cluster for deployment"
  type    = bool
  default = true
}

variable "existed_cluster_id" {
  description = "Cluster where you plan to deploy"
  type    = string
  default = ""
}

variable "cloudbeaver_image_name" {
  description = "The version of the cluster you want to deploy"
  type = string
  default = "cloudbeaver-ee"
}

variable "cloudbeaver_version" {
  description = "The version of the cluster you want to deploy"
  type = string
  default = "24.1.0"
}

variable "alb_certificate_Identifier" {
  description = "Your certificate ID from AWS Certificate Manager"
  type = string
  default = ""
}

variable "cloudbeaver-env" {
  description = "The environment for cloudbeaver"
  # type = map(string)
  default = [{
      "name": "CLOUDBEAVER_PUBLIC_URL",
      "value": "cloudbeaver.io"
  }]
}

variable "task_name" {
  description = "The version of the cluster you want to deploy"
  type = string
  default = "cloudbeaver"
}

variable "cloudbeaver_default_ns" {
  type = string
  default = "cloudbeaver.local"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
 type        = list(string)
 description = "Public Subnet CIDR values"
 default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
 type        = list(string)
 description = "Private Subnet CIDR values"
 default     = ["10.0.4.0/24", "10.0.5.0/24"]
}

variable "common_tags" {
  description = "Common tags for resources"
  type = map(string)
  default = {
    Environment = "dev"
    Project     = "cloudbeaver-ecs-deployment"
  }
}

