################################################################################
# EFS
################################################################################

resource "aws_efs_file_system" "cloudbeaver_data" {
  creation_token = "cloudbeaver_data"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = "false"
  
  tags = merge(var.common_tags, { Name = "Cloudbeaver DATA EFS" })
}

resource "aws_efs_mount_target" "cloudbeaver_data_mt" {
  count = length(aws_subnet.private_subnets)
  file_system_id = aws_efs_file_system.cloudbeaver_data.id
  subnet_id      = aws_subnet.private_subnets[count.index].id
  security_groups = [aws_security_group.cloudbeaver_efs.id]
}

resource "aws_efs_file_system" "api_tokens" {
  creation_token = "api_tokens"
  performance_mode = "generalPurpose"
  throughput_mode = "bursting"
  encrypted = "false"
  
  tags = merge(var.common_tags, { Name = "Cloudbeaver API token EFS" })
}

resource "aws_efs_mount_target" "api_tokens_mt" {
  count = length(aws_subnet.private_subnets)
  file_system_id = aws_efs_file_system.api_tokens.id
  subnet_id      = aws_subnet.private_subnets[count.index].id
  security_groups = [aws_security_group.cloudbeaver_efs.id]
}
