locals {
  aws_region               = ""
  aws_account_id           = ""
  create_cluster           = true
  cluster_name             = "cloudbeaver-ecs-cluster"
  task_name                = "cloudbeaver-task"
  cloudbeaver_version_tag  = "latest"
  cloudbeaver_image_name   = "cloudbeaver-ee"
  container_port           = 8978
  cpu                      = 1024
  memory                   = 2048
  volume_name              = "cloudbeaver_volume"
  network_name             = "cloudbeaver-private-net"
  common_tags = {
    Environment = "prod"
    Project     = "cloudbeaver-ecs-deployment"
  }
  docker_build_cmd = <<-EOT
    cd build

    export AWS_REGION="${local.aws_region}"
    export AWS_ACC_ID="${local.aws_account_id}"

    export CBVERSION="${local.cloudbeaver_version_tag}"
    export CBIMAGENAME="${local.cloudbeaver_image_name}"

    aws ecr get-login-password --region ${local.aws_region} | docker login --username AWS --password-stdin ${local.aws_account_id}.dkr.ecr.${local.aws_region}.amazonaws.com

    docker pull dbeaver/${local.cloudbeaver_image_name}:${local.cloudbeaver_version_tag}
    docker build -t ${local.cloudbeaver_image_name} --build-arg CBVERSION=${local.cloudbeaver_version_tag} -f cb.Dockerfile .
    docker tag ${local.cloudbeaver_image_name} ${local.aws_account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/${local.cloudbeaver_image_name}:${local.cloudbeaver_version_tag}
    docker push ${local.aws_account_id}.dkr.ecr.${local.aws_region}.amazonaws.com/${local.cloudbeaver_image_name}:${local.cloudbeaver_version_tag}

    cd ..
  EOT
}