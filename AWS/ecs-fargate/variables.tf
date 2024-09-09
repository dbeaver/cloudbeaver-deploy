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

variable "cloudbeaver_image_source" {
  description = "The version of the cluster you want to deploy"
  type = string
  default = "dbeaver"
}

variable "cloudbeaver_image_name" {
  description = "The version of the cluster you want to deploy"
  type = string
  default = "cloudbeaver-ee"
}

variable "cloudbeaver_version" {
  description = "The version of the cluster you want to deploy"
  type = string
  default = "24.2.0"
}

variable "alb_certificate_Identifier" {
  description = "Your certificate ID from AWS Certificate Manager"
  type = string
  default = ""
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

variable "cloudbeaver-env" {
  # type = map(string)
  default = [{
      "name": "CLOUDBEAVER_DB_DRIVER",
      "value": "postgres-jdbc"
  },
  {
      "name": "CLOUDBEAVER_DB_URL",
      "value": ""
  },
  {
      "name": "CLOUDBEAVER_DB_USER",
      "value": "postgres"
  },
  {
      "name": "CLOUDBEAVER_DB_PASSWORD",
      "value": "StR0NgP2s"
  },
  {
      "name": "CLOUDBEAVER_DB_SCHEMA",
      "value": "cb"
  },
  {
      "name": "CLOUDBEAVER_QM_DB_DRIVER",
      "value": "postgres-jdbc"
  },
  {
      "name": "CLOUDBEAVER_QM_DB_URL",
      "value": ""
  },
  {
      "name": "CLOUDBEAVER_QM_DB_USER",
      "value": "postgres"
  },
  {
      "name": "CLOUDBEAVER_QM_DB_PASSWORD",
      "value": "StR0NgP2s"
  },
  {
      "name": "CLOUDBEAVER_QM_DB_SCHEMA",
      "value": "qm"
  },
  {
      "name": "CLOUDBEAVER_PUBLIC_URL",
      "value": "test-domain-name.databases.team"
  }]
}

variable "rds_db_type" {
  description = "Type of RDS DB instance"
  type        = string
  default     = "postgres"
}

variable "rds_db_version" {
  description = "Version of type RDS DB instance"
  type        = string
  default     = "16.1"
}

variable "cloudbeaver-db-env" {
  description = "Parameters for your internal database"
  # type = map(string)
  default = [
    { "name": "POSTGRES_PASSWORD",
     "value": "postgres"},
    { "name": "POSTGRES_USER",
     "value": "postgres"},
    { "name": "POSTGRES_DB",
     "value": "cloudbeaver"}
  ]
}