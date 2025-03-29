#!/bin/bash

# Check if tfplan exists
if [ ! -f "tfplan" ]; then
    echo "No terraform plan found. Running terraform plan first..."
    terraform plan -out=tfplan
fi

# Apply the Terraform plan
echo "Applying Terraform configuration..."
terraform apply tfplan

# Remove the plan file after apply
rm tfplan

echo "Deployment complete!"