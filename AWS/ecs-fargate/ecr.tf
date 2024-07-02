resource "aws_ecr_repository" "cloudbeaver" {
  name                 = "${var.cloudbeaver_image_name}"
  image_tag_mutability = "MUTABLE"
  force_delete = "true"

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = var.common_tags
}

locals {

  dkr_build_cmd = <<-EOT

    cd build

    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

    docker pull dbeaver/${var.cloudbeaver_image_name}:${var.cloudbeaver_version}
    docker build -t ${var.cloudbeaver_image_name} --build-arg CBVERSION=${var.cloudbeaver_version} CBIMAGENAME=${var.cloudbeaver_image_name} -f cb.Dockerfile .
    docker tag ${var.cloudbeaver_image_name} ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.cloudbeaver_image_name}:${var.cloudbeaver_version}
    docker push ${var.aws_account_id}.dkr.ecr.${var.aws_region}.amazonaws.com/${var.cloudbeaver_image_name}:${var.cloudbeaver_version}

    cd ..
    EOT

}


# local-exec for build and push of docker image
resource "null_resource" "build_push_dkr_img" {
  depends_on = [aws_ecr_repository.cloudbeaver]
  
  triggers = {
    image_ver_changed = var.cloudbeaver_version
  }
  provisioner "local-exec" {
    command = local.dkr_build_cmd
  }

  
}

output "trigged_by" {
  value = null_resource.build_push_dkr_img.triggers
}