# Terraform K3s Monitoring Stack

This Terraform project deploys a comprehensive monitoring stack to a K3s cluster
running on Proxmox. The stack includes Prometheus and Grafana for monitoring and
visualization.

## Prerequisites

- A running K3s cluster on Proxmox
- Terraform >= 1.0.0
- `kubectl` configured with access to your K3s cluster
- Helm 3.x installed

## Components

- Prometheus (via kube-prometheus-stack)
- Grafana
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

3. Review and modify variables in `variables.tf` as needed.

4. Validate the configuration:

   ```bash
   ./scripts/terraform_validate.sh
   ```

5. Apply the configuration:

   ```bash
   ./scripts/terraform_apply.sh
   ```

## Accessing the Services

After successful deployment:

- Prometheus will be available at:
  `http://prometheus.<namespace>.svc.cluster.local:9090`
- Grafana will be available at: `http://grafana.<namespace>.svc.cluster.local`

## Configuration

- Modify `variables.tf` to customize the deployment
- Additional Prometheus scrape configs can be added in the monitoring-stack
  module
- Custom Grafana dashboards can be added to the monitoring-stack module

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the LICENSE file for
details.
