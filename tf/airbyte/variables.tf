variable "aws_region" {
  type        = string
  description = "AWS region for resources"
  default     = "us-west-2"
}

# Network Variables
variable "vpc_cidr" {
  type        = string
  description = "CIDR block for VPC"
}

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones"
}

variable "public_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for public subnets"
}

variable "private_subnet_cidrs" {
  type        = list(string)
  description = "CIDR blocks for private subnets"
}

variable "single_nat_gateway" {
  type        = bool
  description = "Use single NAT gateway for cost optimization"
  default     = true
}

# RDS Variables
variable "db_instance_class" {
  type        = string
  description = "RDS instance class"
}

variable "db_allocated_storage" {
  type        = number
  description = "Allocated storage in GB"
}

variable "db_engine_version" {
  type        = string
  description = "PostgreSQL engine version"
}

variable "db_name" {
  type        = string
  description = "Database name"
}

variable "db_username" {
  type        = string
  description = "Database master username"
}

variable "db_multi_az" {
  type        = bool
  description = "Enable multi-AZ deployment"
  default     = false
}

# EKS Variables
variable "eks_cluster_version" {
  type        = string
  description = "Kubernetes version"
}

variable "eks_node_instance_types" {
  type        = list(string)
  description = "EC2 instance types for EKS nodes"
}

variable "eks_node_desired_size" {
  type        = number
  description = "Desired number of nodes"
}

variable "eks_node_min_size" {
  type        = number
  description = "Minimum number of nodes"
}

variable "eks_node_max_size" {
  type        = number
  description = "Maximum number of nodes"
}

# Airbyte Variables
variable "airbyte_version" {
  type        = string
  description = "Airbyte chart version"
}

variable "airbyte_namespace" {
  type        = string
  description = "Kubernetes namespace for Airbyte"
  default     = "airbyte"
}
