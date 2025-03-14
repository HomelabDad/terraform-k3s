# Setup Guide

This guide provides detailed instructions for setting up the monitoring stack on
your K3s cluster.

## Prerequisites Setup

1. **K3s Cluster**

   - Ensure your K3s cluster is running on Proxmox
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

3. **Helm Installation**
   - Install Helm 3.x
   - Verify installation:
     ```bash
     helm version
     ```

## Configuration Steps

1. **Kubeconfig Setup**

   - Ensure your kubeconfig is properly configured
   - Default location: `~/.kube/config`
   - You can specify a custom path in `variables.tf`

2. **Namespace Configuration**

   - Default namespace: `monitoring`
   - Can be customized in `variables.tf`

3. **Helm Charts Configuration**
   - Prometheus chart version can be updated in `variables.tf`
   - Grafana chart version can be updated in `variables.tf`

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
   kubectl get pods -n monitoring
   kubectl get services -n monitoring
   ```

2. **Access Services**

   - Get Prometheus URL:
     ```bash
     kubectl get svc -n monitoring prometheus-operated
     ```
   - Get Grafana URL:
     ```bash
     kubectl get svc -n monitoring grafana
     ```

3. **Configure Access**
   - Set up ingress or port forwarding as needed
   - Default Grafana admin credentials will be output after deployment

## Troubleshooting

1. **Common Issues**

   - Check pod status:
     ```bash
     kubectl describe pods -n monitoring
     ```
   - View logs:
     ```bash
     kubectl logs -n monitoring <pod-name>
     ```

2. **Resource Constraints**
   - Monitor resource usage:
     ```bash
     kubectl top pods -n monitoring
     ```
   - Adjust resource limits in Helm values if needed

## Maintenance

1. **Updating Components**

   - Update chart versions in `variables.tf`
   - Run terraform plan and apply

2. **Backup**

   - Regularly backup Grafana dashboards
   - Export Prometheus rules and alerts

3. **Monitoring the Monitor**
   - Set up alerts for monitoring stack health
   - Monitor disk usage for Prometheus storage
