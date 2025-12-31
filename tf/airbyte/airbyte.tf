# Kubernetes namespace for Airbyte
resource "kubernetes_namespace" "airbyte" {
  metadata {
    name = var.airbyte_namespace
    labels = {
      name        = var.airbyte_namespace
      environment = local.env
    }
  }

  depends_on = [module.eks]
}

# Kubernetes service account for Airbyte
resource "kubernetes_service_account" "airbyte" {
  metadata {
    name      = "airbyte-admin"
    namespace = kubernetes_namespace.airbyte.metadata[0].name
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.airbyte_service.arn
    }
  }
}

# Kubernetes secret for database connection
resource "kubernetes_secret" "database" {
  metadata {
    name      = "airbyte-db-secret"
    namespace = kubernetes_namespace.airbyte.metadata[0].name
  }

  type = "Opaque"

  data = {
    DATABASE_HOST     = aws_db_instance.airbyte.address
    DATABASE_PORT     = tostring(aws_db_instance.airbyte.port)
    DATABASE_NAME     = var.db_name
    DATABASE_USER     = var.db_username
    DATABASE_PASSWORD = random_password.db_password.result
    DATABASE_URL      = "jdbc:postgresql://${aws_db_instance.airbyte.address}:${aws_db_instance.airbyte.port}/${var.db_name}"
  }
}

# Helm release for Airbyte
resource "helm_release" "airbyte" {
  name       = "airbyte"
  repository = "https://airbytehq.github.io/helm-charts"
  chart      = "airbyte"
  version    = var.airbyte_version
  namespace  = kubernetes_namespace.airbyte.metadata[0].name

  values = [
    yamlencode({
      global = {
        serviceAccountName = kubernetes_service_account.airbyte.metadata[0].name

        # Database configuration
        database = {
          type     = "external"
          host     = aws_db_instance.airbyte.address
          port     = aws_db_instance.airbyte.port
          database = var.db_name
          user     = var.db_username
          password = random_password.db_password.result
        }

        # Storage configuration
        storage = {
          type   = "S3"
          bucket = aws_s3_bucket.airbyte_logs.id
          region = var.aws_region
        }

        # Environment-specific settings
        env = local.env
      }

      # Webapp configuration
      webapp = {
        enabled      = true
        replicaCount = 1
        service = {
          type = "LoadBalancer"
          annotations = {
            "service.beta.kubernetes.io/aws-load-balancer-type"   = "nlb"
            "service.beta.kubernetes.io/aws-load-balancer-scheme" = "internet-facing"
          }
        }
        resources = {
          requests = {
            cpu    = "500m"
            memory = "1Gi"
          }
          limits = {
            cpu    = "1000m"
            memory = "2Gi"
          }
        }
      }

      # Server configuration
      server = {
        enabled      = true
        replicaCount = 1
        resources = {
          requests = {
            cpu    = "500m"
            memory = "1Gi"
          }
          limits = {
            cpu    = "2000m"
            memory = "4Gi"
          }
        }
      }

      # Worker configuration
      worker = {
        enabled      = true
        replicaCount = 2
        resources = {
          requests = {
            cpu    = "1000m"
            memory = "2Gi"
          }
          limits = {
            cpu    = "2000m"
            memory = "4Gi"
          }
        }
      }

      # Temporal configuration
      temporal = {
        enabled      = true
        replicaCount = 1
      }

      # Disable internal PostgreSQL
      postgresql = {
        enabled = false
      }

      # Disable MinIO
      minio = {
        enabled = false
      }
    })
  ]

  depends_on = [
    aws_eks_addon.ebs_csi_driver,
    aws_db_instance.airbyte,
    kubernetes_secret.database
  ]
}
