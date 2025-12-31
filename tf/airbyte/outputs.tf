output "vpc_id" {
  description = "VPC ID"
  value       = aws_vpc.main.id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = module.eks.cluster_endpoint
  sensitive   = true
}

output "eks_cluster_certificate_authority" {
  description = "EKS cluster certificate authority data"
  value       = module.eks.cluster_certificate_authority_data
  sensitive   = true
}

output "rds_endpoint" {
  description = "RDS endpoint"
  value       = aws_db_instance.airbyte.endpoint
  sensitive   = true
}

output "rds_database_name" {
  description = "RDS database name"
  value       = aws_db_instance.airbyte.db_name
}

output "db_secret_arn" {
  description = "ARN of the secret containing database credentials"
  value       = aws_secretsmanager_secret.db_password.arn
}

output "airbyte_namespace" {
  description = "Kubernetes namespace for Airbyte"
  value       = kubernetes_namespace.airbyte.metadata[0].name
}

output "airbyte_service_account_role_arn" {
  description = "IAM role ARN for Airbyte service account"
  value       = aws_iam_role.airbyte_service.arn
}

output "airbyte_logs_bucket" {
  description = "S3 bucket for Airbyte logs"
  value       = aws_s3_bucket.airbyte_logs.id
}

output "kubeconfig_command" {
  description = "Command to update kubeconfig for this EKS cluster"
  value       = "aws eks update-kubeconfig --region ${var.aws_region} --name ${module.eks.cluster_name}"
}

output "airbyte_loadbalancer_instructions" {
  description = "Instructions to get Airbyte LoadBalancer URL"
  value       = "Run: kubectl get svc -n ${var.airbyte_namespace} airbyte-airbyte-webapp-svc -o jsonpath='{.status.loadBalancer.ingress[0].hostname}'"
}
