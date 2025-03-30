# Terraform K3s Monitoring Stack

This Terraform project deploys a comprehensive infrastructure and monitoring stack to a K3s cluster
running on Proxmox. The stack includes essential components for cluster management, monitoring,
load balancing, and visualization.

## Prerequisites

- A running K3s cluster on Proxmox
- Terraform >= 1.0.0
- `kubectl` configured with access to your K3s cluster
- Helm 3.x installed

## Core Components

### Infrastructure
- MetalLB - Bare metal load balancer for Kubernetes
- Cert-Manager - Certificate management for Kubernetes
- Nginx Ingress Controller - Kubernetes ingress controller

### Monitoring & Management
- Prometheus (via kube-prometheus-stack) - Metrics collection and storage
- Grafana - Metrics visualization and dashboards
- Portainer - Container management UI
- Custom dashboards for K3s monitoring
- Additional scrape configurations

## Directory Structure

```text
terraform-k3s-monitoring/
├── README.md
├── .gitignore
├── main.tf                # Main Terraform configuration
├── providers.tf           # Provider configurations
├── variables.tf           # Input variables
├── outputs.tf            # Output values
├── modules/
│   └── monitoring-stack/  # Custom monitoring configurations
├── scripts/
│   ├── terraform_validate.sh
│   └── terraform_apply.sh
└── docs/
    └── setup.md
```

## Quick Start

1. Clone this repository:

   ```bash
   git clone <repository-url>
   cd terraform-k3s-monitoring
   ```

2. Initialize Terraform:

   ```bash
   terraform init
   ```

3. Create a `terraform.tfvars` file with your network configuration:

   ```hcl
   traefik_load_balancer_ip = "your.traefik.ip"
   metallb_ip_range        = "your.start.ip-your.end.ip"
   ```

   Note: This file should not be committed to version control as it contains sensitive network information.

4. Review and modify variables in `variables.tf` as needed.

5. Validate the configuration:

   ```bash
   ./scripts/terraform_validate.sh
   ```

6. Apply the configuration:

   ```bash
   ./scripts/terraform_apply.sh
   ```

## Accessing the Services

After successful deployment, you can access the services using port forwarding:

### For Grafana (Monitoring)
```bash
kubectl port-forward -n monitoring svc/grafana 3000:80
```
Access at: `http://localhost:3000`

### For Prometheus (Metrics)
```bash
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
```
Access at: `http://localhost:9090`

### For Portainer (Container Management)
```bash
kubectl port-forward -n portainer svc/portainer 9443:9443
```
Access at: `https://localhost:9443`

## Configuration

- Modify `variables.tf` to customize the deployment
- Additional Prometheus scrape configs can be added in the monitoring-stack module
- Custom Grafana dashboards can be added to the monitoring-stack module
- MetalLB configuration can be adjusted for your specific network requirements
- Ingress configurations can be modified in the respective Terraform configurations

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for
details.

## Initial Setup Note

To manage the cluster from your local machine, copy the K3s configuration using:

```bash
ssh -i ~/.ssh/id_rsa ubuntu@10.27.3.100 'sudo cat /etc/rancher/k3s/k3s.yaml' > ~/.kube/config
```

Remember to update the IP address to match your K3s control node.