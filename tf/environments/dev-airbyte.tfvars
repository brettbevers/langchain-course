# Network Configuration
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-west-2a", "us-west-2b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.11.0/24"]
single_nat_gateway   = true  # Cost optimization for dev

# RDS Configuration
db_instance_class    = "db.t3.medium"
db_allocated_storage = 50
db_engine_version    = "15.4"
db_name              = "airbyte"
db_username          = "airbyte_admin"
db_multi_az          = false  # Set true for prod

# EKS Configuration
eks_cluster_version     = "1.29"
eks_node_instance_types = ["t3.medium"]
eks_node_desired_size   = 2
eks_node_min_size       = 1
eks_node_max_size       = 4

# Airbyte Configuration
airbyte_version   = "0.50.0"
airbyte_namespace = "airbyte"
