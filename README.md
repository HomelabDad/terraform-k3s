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

### Logging & AI Analysis
- Loki - Log aggregation and storage with S3 backend (MinIO)
- Promtail - Log collection agent
- MinIO - S3-compatible object storage for log retention
- AI-powered log analysis with vector database integration
- Telegram bot integration for log alerts

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
│   ├── monitoring/        # Monitoring stack (Prometheus, Grafana)
│   ├── loki/             # Logging stack (Loki, MinIO, Promtail)
│   ├── traefik/          # Ingress controller
│   ├── metallb/          # Load balancer
│   ├── portainer/        # Container management
│   └── minecraft/        # Minecraft server
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

   Or use the automated deployment script for the Loki logging stack:

   ```bash
   ./scripts/deploy_loki.sh
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

### For Loki (Logging)
```bash
kubectl port-forward -n logging svc/loki 3100:3100
```
Access at: `http://localhost:3100`

### For MinIO (Object Storage)
```bash
kubectl port-forward -n logging svc/minio 9000:9000
kubectl port-forward -n logging svc/minio-console 9001:9001
```
Access at: `http://localhost:9000` (API) and `http://localhost:9001` (Console)

## Configuration

- Modify `variables.tf` to customize the deployment
- Additional Prometheus scrape configs can be added in the monitoring module
- Custom Grafana dashboards can be added to the monitoring module
- MetalLB configuration can be adjusted for your specific network requirements
- Ingress configurations can be modified in the respective Terraform configurations
- Loki retention and storage settings can be configured in the loki module
- AI log analysis can be customized using the provided Python scripts

## Logging & AI Analysis

The project includes a comprehensive logging solution with AI-powered analysis capabilities:

### Loki Logging Stack
- **Loki**: Centralized log aggregation with S3 storage backend
- **MinIO**: S3-compatible object storage for long-term log retention
- **Promtail**: Log collection agent for Kubernetes pods and system logs
- **Grafana Integration**: Native Loki datasource for log visualization

### AI-Powered Log Analysis
- **Vector Database**: ChromaDB for semantic log search
- **Embedding Model**: Sentence transformers for log content analysis
- **Python Scripts**: Ready-to-use tools for log processing and analysis
- **Telegram Integration**: Automated log alerting via Telegram bot

### Usage Examples

```bash
# Install AI analysis dependencies
pip install -r scripts/requirements.txt

# Fetch and process logs for AI analysis
python scripts/ai_log_analyzer.py --action fetch

# Search logs semantically
python scripts/ai_log_analyzer.py --action search --search-query "database connection error"

# Analyze log patterns
python scripts/ai_log_analyzer.py --action analyze --time-range 24h

# Send Telegram alerts for errors
python scripts/ai_log_analyzer.py --action alert --query '{job="kubernetes-pods"} |= "error"'
```

For detailed documentation, see [docs/loki-setup.md](docs/loki-setup.md).

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