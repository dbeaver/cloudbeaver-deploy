provider "aws" {
  region = var.aws_region
}

################################################################################
# CloudBeaver ECS Cluster
################################################################################

resource "aws_ecs_cluster" "cloudbeaver" {
  name = "cloudbeaver"

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
   aws_ecs_cluster.cloudbeaver
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
  volume {
    name = "api_tokens"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.api_tokens.id
      root_directory = "/"
    }
  }

  container_definitions = jsonencode([{
    name        = "${var.task_name}"
    image       = "${var.cloudbeaver_image_source}/${var.cloudbeaver_image_name}:${var.cloudbeaver_version}"
    essential   = true
    environment = local.updated_cloudbeaver_env
    logConfiguration = {
                "logDriver": "awslogs"
                "options": {
                    "awslogs-group": "${var.task_name}",
                    "awslogs-region": "${var.aws_region}",
                    "awslogs-create-group": "true",
                    "awslogs-stream-prefix": "cb"
                }
    }
    mountPoints = [
      {
        containerPath = "/opt/cloudbeaver/workspace",
        sourceVolume  = "cloudbeaver_data"
      },
      {
        containerPath = "/opt/cloudbeaver/conf/keys/"
        sourceVolume  = "api_tokens"
      }
    ]
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
    aws_lb_target_group.cloudbeaver,
    aws_db_instance.rds_dbeaver_db
  ]

  name            = "${var.task_name}"
  cluster         = aws_ecs_cluster.cloudbeaver.id
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


locals {

  rds_db_url = "jdbc:postgresql://${try(aws_db_instance.rds_dbeaver_db.address, "")}:5432/cloudbeaver"

  cloudbeaver_env_modified = [
    for item in var.cloudbeaver-env : {
      name  = item.name
      value = (
        item.name == "CLOUDBEAVER_DB_URL" ? local.rds_db_url :
        item.name == "CLOUDBEAVER_QM_DB_URL" ? local.rds_db_url :
        item.value
      )
    }
  ]
  
  postgres_password = { for item in var.cloudbeaver-db-env : item.name => item.value }["POSTGRES_PASSWORD"]
  postgres_user     = { for item in var.cloudbeaver-db-env : item.name => item.value }["POSTGRES_USER"]

  updated_cloudbeaver_env = [for item in local.cloudbeaver_env_modified : {
    name  = item.name
    value = (
      item.name == "CLOUDBEAVER_DB_PASSWORD" ? local.postgres_password :
      item.name == "CLOUDBEAVER_QM_DB_PASSWORD" ? local.postgres_password :
      item.name == "CLOUDBEAVER_DB_USER" ? local.postgres_user :
      item.name == "CLOUDBEAVER_QM_DB_USER" ? local.postgres_user :
      item.value
    )
  }]
}
