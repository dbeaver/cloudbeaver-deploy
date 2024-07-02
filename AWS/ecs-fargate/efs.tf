resource "aws_efs_file_system" "cloudbeaver" {
  creation_token = "cloudbeaver-efs"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = "false"
  tags = local.common_tags
}

resource "aws_efs_mount_target" "cloudbeaver" {
  depends_on = [
    aws_efs_file_system.cloudbeaver,
    aws_security_group.efs_sg
  ]
  for_each = { for idx, subnet in aws_subnet.main : idx => subnet.id }

  file_system_id  = aws_efs_file_system.cloudbeaver.id
  subnet_id       = each.value
  security_groups = [aws_security_group.efs_sg.id]
}


# module "efs" {
#   source  = "terraform-aws-modules/efs/aws"
#   version = "~> 2.0"

#   create = true

#   performance_mode = "generalPurpose"
#   throughput_mode  = "bursting"
#   encrypted        = false

#   mount_targets = [
#     for subnet in aws_subnet.main : {
#       subnet_id       = subnet.id
#       security_groups = [aws_security_group.efs_sg.id]
#     }
#   ]

#   tags = local.common_tags
# }