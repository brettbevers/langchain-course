module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = "${local.name_prefix}-eks"
  cluster_version = var.eks_cluster_version

  vpc_id     = aws_vpc.main.id
  subnet_ids = aws_subnet.private[*].id

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # Security groups
  cluster_security_group_id               = aws_security_group.eks_cluster.id
  cluster_additional_security_group_ids   = []
  node_security_group_additional_rules    = {}

  # EKS Managed Node Group
  eks_managed_node_groups = {
    main = {
      min_size     = var.eks_node_min_size
      max_size     = var.eks_node_max_size
      desired_size = var.eks_node_desired_size

      instance_types = var.eks_node_instance_types
      capacity_type  = "ON_DEMAND"

      iam_role_arn = aws_iam_role.eks_nodes.arn

      vpc_security_group_ids = [aws_security_group.eks_nodes.id]

      tags = merge(
        local.common_tags,
        {
          Name = "${local.name_prefix}-node-group"
        }
      )
    }
  }

  # Cluster IAM role
  iam_role_arn = aws_iam_role.eks_cluster.arn

  # Enable IRSA
  enable_irsa = true

  # Cluster addons (managed separately in eks_addons.tf)
  cluster_addons = {}

  tags = local.common_tags
}

# Grant service user access to the EKS cluster
resource "aws_eks_access_entry" "service_user" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::016784657549:user/service"
  type          = "STANDARD"

  depends_on = [module.eks]
}

resource "aws_eks_access_policy_association" "service_user_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::016784657549:user/service"
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.service_user]
}
