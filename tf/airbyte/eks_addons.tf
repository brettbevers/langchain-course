# EBS CSI Driver Add-on
resource "aws_eks_addon" "ebs_csi_driver" {
  cluster_name             = module.eks.cluster_name
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.25.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.ebs_csi_driver.arn

  tags = local.common_tags

  depends_on = [module.eks]
}

# VPC CNI Add-on
resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "vpc-cni"
  addon_version = "v1.15.0-eksbuild.2"

  tags = local.common_tags

  depends_on = [module.eks]
}

# CoreDNS Add-on
resource "aws_eks_addon" "coredns" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "coredns"
  addon_version = "v1.10.1-eksbuild.2"

  tags = local.common_tags

  depends_on = [module.eks]
}

# Kube-proxy Add-on
resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = module.eks.cluster_name
  addon_name    = "kube-proxy"
  addon_version = "v1.28.1-eksbuild.1"

  tags = local.common_tags

  depends_on = [module.eks]
}
