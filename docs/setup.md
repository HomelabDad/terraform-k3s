# Setup Guide

This guide provides detailed instructions for setting up your K3s cluster infrastructure using Terraform.

## Prerequisites Setup

1. **K3s Cluster**
   - Ensure your K3s cluster is running
   - Verify cluster access:
     ```bash
     kubectl cluster-info
     ```

2. **Terraform Installation**
   - Install Terraform >= 1.0.0
   - Verify installation:
     ```bash
     terraform --version
     ```

## Configuration Steps

1. **Kubeconfig Setup**
   - Ensure your kubeconfig is properly configured
   - Default location: `~/.kube/config`
   - You can specify a custom path in `variables.tf`

2. **Module Configuration**
   The project includes the following modules:
   - **Monitoring**: Prometheus and Grafana stack
   - **MetalLB**: Load balancer for bare metal clusters
   - **Traefik**: Ingress controller
   - **Portainer**: Container management UI

   Each module can be configured through its respective variables in the module directory.

## Deployment

1. **Initialize Terraform**
   ```bash
   terraform init
   ```

2. **Review Configuration**
   ```bash
   terraform plan
   ```

3. **Apply Configuration**
   ```bash
   terraform apply
   ```

## Post-Deployment

1. **Verify Deployment**
   ```bash
   kubectl get pods -A
   kubectl get services -A
   ```

2. **Access Services**
   - Get Portainer URL:
     ```bash
     kubectl get svc -n portainer portainer
     ```
   - Get Traefik Dashboard:
     ```bash
     kubectl get svc -n traefik traefik
     ```
   - Get Monitoring Stack:
     ```bash
     kubectl get svc -n monitoring
     ```

3. **Configure Access**
   - MetalLB will automatically assign external IPs to services
   - Configure DNS resolution:
     - Option 1: Add entries to your local hosts file
     - Option 2: Configure DNS resolution in your router
     - Option 3: Set up Pi-hole with local DNS records
   - Services can be accessed via their DNS names once configured
   - Default credentials will be output after deployment

## Troubleshooting

1. **Common Issues**
   - Check pod status:
     ```bash
     kubectl describe pods -n <namespace>
     ```
   - View logs:
     ```bash
     kubectl logs -n <namespace> <pod-name>
     ```

2. **Resource Constraints**
   - Monitor resource usage:
     ```bash
     kubectl top pods -A
     ```
   - Adjust resource limits in module configurations if needed

## Maintenance

1. **Updating Components**
   - Update module versions in respective module directories
   - Run terraform plan and apply

2. **Backup**
   - Regularly backup Portainer configurations
   - Export monitoring dashboards and alerts
   - Backup Terraform state file

3. **Monitoring**
   - Use the monitoring stack to track cluster health
   - Monitor MetalLB IP allocation
   - Track Traefik ingress traffic

## Project Structure

```
.
├── modules/
│   ├── monitoring/    # Prometheus and Grafana stack
│   ├── metallb/       # Load balancer configuration
│   ├── traefik/       # Ingress controller
│   └── portainer/     # Container management UI
├── scripts/           # Utility scripts
├── docs/             # Documentation
└── main.tf           # Main Terraform configuration
```
