resource "aws_ecr_repository" "dbeaver_cloudbeaver" {
  name                 = local.cloudbeaver_image_name
  image_tag_mutability = "MUTABLE"
  force_delete = "true"

  image_scanning_configuration {
    scan_on_push = false
  }
}

resource "null_resource" "build_push_dkr_img" {
  triggers = {
    image_ver_changed = local.cloudbeaver_version_tag
  }
  provisioner "local-exec" {
    command = local.docker_build_cmd
  }

  depends_on = [aws_ecr_repository.dbeaver_cloudbeaver]
}

output "trigged_by" {
  value = null_resource.build_push_dkr_img.triggers
}