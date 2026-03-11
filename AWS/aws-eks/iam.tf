data "aws_eks_node_groups" "nodegroups" {
  cluster_name = var.cluster_name
}

data "aws_eks_node_group" "nodegroup" { 
  for_each = toset(data.aws_eks_node_groups.nodegroups.names)

  cluster_name    = var.cluster_name
  node_group_name = each.value
}

resource "aws_iam_role_policy_attachment" "ebs_csi_policy_attachment" {
  for_each = data.aws_eks_node_group.nodegroup

  role       = basename(each.value.node_role_arn)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

resource "aws_iam_role_policy_attachment" "efs_csi_policy_attachment" {
  for_each = data.aws_eks_node_group.nodegroup

  role       = basename(each.value.node_role_arn)
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEFSCSIDriverPolicy"
}

