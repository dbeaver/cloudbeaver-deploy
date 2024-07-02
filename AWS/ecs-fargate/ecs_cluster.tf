module "ecs_cluster" {
  depends_on = [
    aws_ecr_repository.dbeaver_cloudbeaver,
    null_resource.build_push_dkr_img
  ]
  source  = "terraform-aws-modules/ecs/aws//modules/cluster"
  version = "~> 5.0"
  
  create       = local.create_cluster
  cluster_name = local.cluster_name

  cluster_configuration = {
    execute_command_configuration = {
      logging = "OVERRIDE"
      log_configuration = {
        cloud_watch_log_group_name = "/aws/ecs/aws-ec2"
      }
    }
  }

  fargate_capacity_providers = {
    FARGATE = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
    FARGATE_SPOT = {
      default_capacity_provider_strategy = {
        weight = 50
      }
    }
  }

  tags = local.common_tags
}
