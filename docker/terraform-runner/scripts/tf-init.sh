#!/bin/sh

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
    echo "ERROR: environment and service must be provided."
    exit 1    
fi

environment=$1
service=$2
tf_workspace="$environment-$service"
tf_path="/usr/src/tf"
backend_file="$tf_path/backends/$environment.tfvars"

# Check if Terraform is installed.
terraform -v

# Initialize the Terraform project.
cd "$tf_path/$service"
terraform init -backend-config=$backend_file -input=false

# Select or create the Terraform workspace.
terraform workspace select -or-create $tf_workspace

# Initialize the Terraform workspace.
terraform init -backend-config=$backend_file -input=false

# Validate the Terraform project.
terraform validate -no-color 
