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

# Note that these two files will be the same when deploying common
var_file_common="$tf_path/environments/$environment-common.tfvars"
var_file_service="$tf_path/environments/$environment-$service.tfvars"

echo "INFO: Starting plan of Terraform workspace $1"

# Initialize the Terraform project.
/usr/src/tf-init.sh $environment $service > /dev/null

# Create plan and pass through any arguments
cd $tf_path/$service
terraform plan -var-file $var_file_common -var-file $var_file_service -lock=false -no-color
