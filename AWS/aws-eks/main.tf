provider "aws" {
  region = var.region
}

variable "region" {
  description = "Region for AWS EFS"
  default     = ""
}

variable "cluster_name" {
  description = "EKS cluster name"
  default     = ""
}

variable "efs_name" {
  description = "Name for EFS"
  default     = "CloudBeaver-EKS-EFS"
}

data "aws_eks_cluster" "eks_cluster" {
  name = var.cluster_name
} 