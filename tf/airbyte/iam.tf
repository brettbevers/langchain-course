# EKS Cluster IAM Role
resource "aws_iam_role" "eks_cluster" {
  name_prefix = "${local.name_prefix}-eks-cluster-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "eks.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks_cluster.name
}

# EKS Node IAM Role
resource "aws_iam_role" "eks_nodes" {
  name_prefix = "${local.name_prefix}-eks-nodes-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks_nodes.name
}

resource "aws_iam_role_policy_attachment" "eks_container_registry_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks_nodes.name
}

# EBS CSI Driver IAM Role
resource "aws_iam_role" "ebs_csi_driver" {
  name_prefix = "${local.name_prefix}-ebs-csi-driver-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
      Condition = {
        StringEquals = {
          "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:kube-system:ebs-csi-controller-sa"
        }
      }
    }]
  })

  tags = local.common_tags
}

resource "aws_iam_role_policy_attachment" "ebs_csi_driver_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
  role       = aws_iam_role.ebs_csi_driver.name
}

# Airbyte Service Account IAM Role
resource "aws_iam_role" "airbyte_service" {
  name_prefix = "${local.name_prefix}-airbyte-service-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = module.eks.oidc_provider_arn
      }
      Condition = {
        StringEquals = {
          "${module.eks.oidc_provider}:aud" = "sts.amazonaws.com"
          "${module.eks.oidc_provider}:sub" = "system:serviceaccount:${var.airbyte_namespace}:airbyte-admin"
        }
      }
    }]
  })

  tags = local.common_tags
}

# S3 Bucket for Airbyte logs and artifacts
resource "aws_s3_bucket" "airbyte_logs" {
  bucket_prefix = "${local.name_prefix}-logs-"

  tags = local.common_tags
}

resource "aws_s3_bucket_versioning" "airbyte_logs" {
  bucket = aws_s3_bucket.airbyte_logs.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "airbyte_logs" {
  bucket = aws_s3_bucket.airbyte_logs.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 access policy for Airbyte
resource "aws_iam_policy" "airbyte_s3_access" {
  name_prefix = "${local.name_prefix}-airbyte-s3-"
  description = "Allow Airbyte to access S3 for logs and artifacts"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "s3:PutObject",
        "s3:GetObject",
        "s3:ListBucket",
        "s3:DeleteObject"
      ]
      Resource = [
        aws_s3_bucket.airbyte_logs.arn,
        "${aws_s3_bucket.airbyte_logs.arn}/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "airbyte_s3_access" {
  policy_arn = aws_iam_policy.airbyte_s3_access.arn
  role       = aws_iam_role.airbyte_service.name
}
