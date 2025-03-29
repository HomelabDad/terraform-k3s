#!/bin/bash

# Initialize Terraform if not already initialized
if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init
fi

# Format Terraform files
echo "Formatting Terraform files..."
terraform fmt -recursive

# Validate Terraform configuration
echo "Validating Terraform configuration..."
terraform validate

# Check for any plan changes
echo "Checking for plan changes..."
terraform plan -out=tfplan

echo "Validation complete!"