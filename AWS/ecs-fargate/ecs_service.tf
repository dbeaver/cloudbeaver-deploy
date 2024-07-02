module "ecs_service" {
  depends_on = [
    module.ecs_cluster,
    aws_security_group.allow_all,
    aws_efs_mount_target.cloudbeaver
  ]
  source  = "terraform-aws-modules/ecs/aws//modules/service"
  version = "~> 5.0"

  name              = local.task_name
  cluster_arn       = local.create_cluster ? module.ecs_cluster.arn : local.cluster_name
  family                = local.task_name
  container_definitions = [
    {
      name      = local.task_name
      image     = "${local.aws_account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/${local.cloudbeaver_image_name}:${local.cloudbeaver_version_tag}"
      essential = true
      readonly_root_filesystem = false
      portMappings = [
        {
          containerPort = local.container_port
          hostPort      = local.container_port
        }
      ]
      mountPoints = [
        {
          sourceVolume  = local.volume_name
          containerPath = "/opt/cloudbeaver/workspace"
        }
      ]
    }
  ]
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = local.cpu
  memory                   = local.memory
  volume = [
      {
      name = local.volume_name
      efsVolumeConfiguration = {
          fileSystemId = aws_efs_file_system.cloudbeaver.id
          root_directory = "/"
      }
      }
  ]

  desired_count    = 1
  launch_type      = "FARGATE"

  subnet_ids = aws_subnet.main[*].id
  security_group_ids = [aws_security_group.allow_all.id]
  assign_public_ip = true

  tags = local.common_tags
}
