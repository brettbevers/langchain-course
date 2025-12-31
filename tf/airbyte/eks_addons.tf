# EBS CSI Driver Add-on
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  # Use default version compatible with cluster version
  resolve_conflicts_on_create = "OVERWRITE"

  tags = local.common_tags

  depends_on = [module.eks]
}

# VPC CNI Add-on
resource "aws_eks_addon" "vpc_cni" {
  cluster_name = module.eks.cluster_name
  addon_name   = "vpc-cni"

  # Use default version compatible with cluster version
  resolve_conflicts_on_create = "OVERWRITE"

  tags = local.common_tags

  depends_on = [module.eks]
}

# CoreDNS Add-on
resource "aws_eks_addon" "coredns" {
  cluster_name = module.eks.cluster_name
  addon_name   = "coredns"

  # Use default version compatible with cluster version
  resolve_conflicts_on_create = "OVERWRITE"

  tags = local.common_tags

  depends_on = [module.eks]
}

# Kube-proxy Add-on
resource "aws_eks_addon" "kube_proxy" {
  cluster_name = module.eks.cluster_name
  addon_name   = "kube-proxy"

  # Use default version compatible with cluster version
  resolve_conflicts_on_create = "OVERWRITE"

  tags = local.common_tags

  depends_on = [module.eks]
}
