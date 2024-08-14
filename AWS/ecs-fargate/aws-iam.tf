data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_policy" "CloudbeaverEFSAccessPolicy" {
  name        = "CloudbeaverEFSAccessPolicy"
  description = "Policy to allow access only to specific EFS resources"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "elasticfilesystem:DescribeFileSystems",
          "elasticfilesystem:DescribeMountTargets",
          "elasticfilesystem:DescribeMountTargetSecurityGroups",
          "elasticfilesystem:DescribeTags",
          "elasticfilesystem:CreateMountTarget",
          "elasticfilesystem:DeleteMountTarget",
          "elasticfilesystem:ModifyMountTargetSecurityGroups",
          "elasticfilesystem:ListTagsForResource",
          "elasticfilesystem:TagResource",
          "elasticfilesystem:UntagResource"
        ]
        Resource = [
          aws_efs_file_system.cloudbeaver_data.arn
        ]
      },
      {
        Effect   = "Allow"
        Action   = [
          "elasticfilesystem:CreateTags",
          "elasticfilesystem:DeleteTags",
          "elasticfilesystem:DescribeFileSystemPolicy",
          "elasticfilesystem:PutFileSystemPolicy"
        ]
        Resource = [
          aws_efs_file_system.cloudbeaver_data.arn
        ]
      }
    ]
  })

  depends_on = [
    aws_efs_file_system.cloudbeaver_data
  ]
}

resource "aws_iam_role" "ecsTaskExecutionRole" {
  name               = "ecsTaskExecutionRole"
  assume_role_policy = "${data.aws_iam_policy_document.assume_role_policy.json}"
}



resource "aws_iam_role_policy_attachment" "ecsTaskExecutionRole_policy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "CloudbeaverEFSAccessPolicy" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "${aws_iam_policy.CloudbeaverEFSAccessPolicy.arn}"
}
resource "aws_iam_role_policy_attachment" "logs_policy_attachment" {
  role       = "${aws_iam_role.ecsTaskExecutionRole.name}"
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
}
