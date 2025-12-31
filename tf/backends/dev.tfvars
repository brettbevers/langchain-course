# Backend configuration for dev environment
# Currently using local backend for Airbyte service
# No backend configuration needed for local state

# For S3 backend (production), uncomment and configure:
# bucket = "your-terraform-state-bucket"
# key    = "PREFIX/terraform.tfstate"  # PREFIX will be the service name
# region = "us-west-2"
# dynamodb_table = "terraform-state-lock"
# encrypt = true
