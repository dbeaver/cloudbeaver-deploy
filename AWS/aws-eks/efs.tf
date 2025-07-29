data "aws_vpc" "vpc" {
  id = data.aws_eks_cluster.eks_cluster.vpc_config[0].vpc_id
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.vpc.id]
  }
}

data "aws_security_group" "eks_security_group" {
  id = data.aws_eks_cluster.eks_cluster.vpc_config[0].cluster_security_group_id
}

data "aws_subnet" "subnet_info" {
  for_each = toset(data.aws_subnets.subnets.ids)
  id       = each.value
}

locals {
  subnets_by_az = { for subnet in data.aws_subnet.subnet_info : subnet.availability_zone => subnet.id... }
  unique_subnet_ids = [for az, subnet_ids in local.subnets_by_az : subnet_ids[0]]
}

resource "aws_efs_file_system" "efs" {
  creation_token   = var.efs_name
  performance_mode = "generalPurpose"
  throughput_mode  = "bursting"
  
  tags = {
    Name = var.efs_name
    CloudBeaver-EE = "true"
  }
}

resource "aws_efs_mount_target" "efs_mount_target" {
  for_each       = toset(local.unique_subnet_ids)
  file_system_id = aws_efs_file_system.efs.id
  subnet_id      = each.key
  security_groups = [data.aws_security_group.eks_security_group.id]
}

resource "aws_efs_access_point" "efs_access_point" {
  file_system_id = aws_efs_file_system.efs.id

  posix_user {
    gid = 8978
    uid = 8978
  }

  root_directory {
    path = "/"
    creation_info {
      owner_gid   = 8978
      owner_uid   = 8978
      permissions = "775"
    }
  }
}

output "efs_file_system_id" {
  value = aws_efs_file_system.efs.id
  description = "EFS file system ID for CloudBeaver EE"
} 