provider "aws" {
  region = var.aws_region
}

################################################################################
# CloudBeaver ECS Cluster
################################################################################

resource "aws_ecs_cluster" "cloudbeaver" {
  depends_on = [
    aws_ecr_repository.cloudbeaver,
    null_resource.build_push_dkr_img
  ]

  name = "cloudbeaver"
  count = var.create_cluster ? 1 : 0  

  tags = var.common_tags
}

################################################################################
# Namespace
################################################################################

resource "aws_service_discovery_private_dns_namespace" "cloudbeaver" {
  name        = var.cloudbeaver_default_ns
  description = "Cloudbeaver SD Namespace"
  vpc         = aws_vpc.cloudbeaver_net.id

  tags = var.common_tags
}


################################################################################
# CloudBeaver ECS Task
################################################################################

resource "aws_ecs_task_definition" "cloudbeaver-task" {

  depends_on = [
   aws_ecs_cluster.cloudbeaver[0]
  ]

  family                   = "${var.task_name}"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 2048
  memory                   = 4096
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  volume {
    name      = "cloudbeaver_data"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.cloudbeaver_data.id
      root_directory = "/"
    }
  }

  container_definitions = jsonencode([{
    name        = "${var.task_name}"
    image       = "${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.cloudbeaver_image_name}:${var.cloudbeaver_version}"
    essential   = true
    logConfiguration = {
                "logDriver": "awslogs"
                "options": {
                    "awslogs-group": "${var.task_name}",
                    "awslogs-region": "${var.aws_region}",
                    "awslogs-create-group": "true",
                    "awslogs-stream-prefix": "cb"
                }
    }
    mountPoints = [{
              "containerPath": "/opt/cloudbeaver/workspace",
              "sourceVolume": "cloudbeaver_data"
    }]
    portMappings = [{
      name = "${var.task_name}"
      protocol      = "tcp"
      containerPort = 8978
      hostPort      = 8978
    }]
  }])

  tags = var.common_tags
}

resource "aws_ecs_service" "cloudbeaver" {

  depends_on = [
    aws_ecs_task_definition.cloudbeaver-task,
    aws_security_group.cloudbeaver,
    aws_lb_target_group.cloudbeaver
  ]

  name            = "${var.task_name}"
  cluster         = var.create_cluster ? aws_ecs_cluster.cloudbeaver[0].id : var.existed_cluster_id
  task_definition = aws_ecs_task_definition.cloudbeaver-task.arn
  launch_type     = "FARGATE"
  desired_count   = 1

  network_configuration {
    security_groups = [aws_security_group.cloudbeaver.id]
    subnets          = aws_subnet.private_subnets[*].id
    assign_public_ip = false
  }
  service_connect_configuration {
    enabled = true
    namespace = aws_service_discovery_private_dns_namespace.cloudbeaver.arn
    service {
      port_name = "${var.task_name}"
      client_alias {
        dns_name = "${var.task_name}"
        port = 8978
      }
    }
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.cloudbeaver.arn
    container_name   = "${var.task_name}"
    container_port   = 8978
  }

  tags = var.common_tags
}
