# Kubernetes namespace for Airbyte
resource "kubernetes_namespace" "airbyte" {
  metadata {
    name = var.airbyte_namespace
    labels = {
      name        = var.airbyte_namespace
      environment = local.env
    }
  }

  depends_on = [
    module.eks,
    aws_eks_access_entry.service_user,
    aws_eks_access_policy_association.service_user_admin
  ]
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

# Install Airbyte using Helm Chart V2 (version 1.9.2 / App 2.0.1)
# Configuration validated against official Chart V2 documentation
resource "helm_release" "airbyte" {
  name       = "airbyte"
  repository = "https://airbytehq.github.io/helm-charts"
  chart      = "airbyte"
  version    = var.airbyte_version
  namespace  = kubernetes_namespace.airbyte.metadata[0].name

  # Service account for IRSA
  set {
    name  = "global.serviceAccountName"
    value = kubernetes_service_account.airbyte.metadata[0].name
  }

  # S3 Storage (Chart V2 schema)
  set {
    name  = "global.storage.type"
    value = "s3"
  }

  set {
    name  = "global.storage.bucket.log"
    value = aws_s3_bucket.airbyte_logs.id
  }

  set {
    name  = "global.storage.bucket.state"
    value = aws_s3_bucket.airbyte_logs.id
  }

  set {
    name  = "global.storage.bucket.workloadOutput"
    value = aws_s3_bucket.airbyte_logs.id
  }

  set {
    name  = "global.storage.bucket.activityPayload"
    value = aws_s3_bucket.airbyte_logs.id
  }

  set {
    name  = "global.storage.s3.region"
    value = "us-west-2"
  }

  set {
    name  = "global.storage.s3.authenticationType"
    value = "instanceProfile"
  }

  # Disable internal PostgreSQL
  set {
    name  = "postgresql.enabled"
    value = "false"
  }

  # Disable internal MinIO
  set {
    name  = "minio.enabled"
    value = "false"
  }

  # External database configuration - Chart V2 official schema
  set {
    name  = "global.database.type"
    value = "external"
  }

  set {
    name  = "global.database.secretName"
    value = kubernetes_secret.database.metadata[0].name
  }

  set {
    name  = "global.database.host"
    value = aws_db_instance.airbyte.address
  }

  set {
    name  = "global.database.port"
    value = "5432"
  }

  set {
    name  = "global.database.name"
    value = var.db_name
  }

  set {
    name  = "global.database.database"
    value = var.db_name
  }

  set {
    name  = "global.database.userSecretKey"
    value = "DATABASE_USER"
  }

  set {
    name  = "global.database.passwordSecretKey"
    value = "DATABASE_PASSWORD"
  }

  # Expose server as LoadBalancer
  set {
    name  = "server.service.type"
    value = "LoadBalancer"
  }

  depends_on = [
    aws_eks_addon.ebs_csi_driver,
    kubernetes_secret.database,
    kubernetes_service_account.airbyte
  ]
}
