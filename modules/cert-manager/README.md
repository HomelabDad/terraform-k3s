# Cert-Manager Module for Local Development

This module deploys cert-manager to your Kubernetes cluster and configures self-signed certificate issuers for local development with `.local` domains.

## Features

- Deploys cert-manager using Helm
- Configures a self-signed certificate issuer
- Creates a local Certificate Authority (CA)
- Automatic certificate renewal

## Usage

```hcl
module "cert_manager" {
  source = "./modules/cert-manager"
}
```

## Using Certificates in Your Applications

To use certificates in your applications, add annotations to your ingress resources:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  annotations:
    cert-manager.io/cluster-issuer: "local-ca-issuer"
spec:
  tls:
  - hosts:
    - your-app.vermillion.local
    secretName: your-app-tls
```

## Requirements

- Kubernetes cluster
- Traefik ingress controller
- Helm provider configured
- Kubernetes provider configured

## Important Notes

1. This configuration uses self-signed certificates suitable for local development
2. The local CA certificate is valid for 10 years
3. Individual certificates will automatically renew when they're within 30 days of expiration
4. To trust the certificates in your browser:
   - After deployment, get the CA certificate:
     ```bash
     kubectl get secret local-ca-key-pair -n cert-manager -o jsonpath="{.data['tls\.crt']}" | base64 -d > local-ca.crt
     ```
   - Import `local-ca.crt` into your browser's/system's trusted root certificates
5. The certificates will work with `.local` domains when properly configured in your hosts file 