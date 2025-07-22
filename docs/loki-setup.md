# Loki Logging Setup

This document describes the Loki logging infrastructure deployed in your K3s cluster.

## 🏗 Architecture Overview

The logging stack consists of:

- **Loki**: Log aggregation and storage system
- **MinIO**: S3-compatible object storage backend
- **Promtail**: Log collection agent
- **Grafana**: Log visualization and querying

```
[ Kubernetes Pods ] → [ Promtail ] → [ Loki ] → [ MinIO S3 Storage ]
                              ↓
                        [ Grafana ] → [ Log Queries & Dashboards ]
```

## 🚀 Quick Start

### 1. Deploy the Stack

```bash
# Apply the Terraform configuration
terraform apply

# Check the deployment
kubectl get pods -n logging
kubectl get pods -n monitoring
```

### 2. Access Services

- **Grafana**: http://grafana.vermillion.local (admin/admin)
- **Loki**: http://loki.vermillion.local
- **MinIO**: http://minio.logging.svc.cluster.local:9000 (minioadmin/minioadmin)

### 3. View Logs in Grafana

1. Open Grafana
2. Go to **Explore** → **Loki**
3. Use LogQL queries to search logs:

```logql
# All logs
{job="kubernetes-pods"}

# Specific namespace
{namespace="monitoring"}

# Specific pod
{pod="prometheus-kube-prometheus-prometheus-0"}

# Error logs
{job="kubernetes-pods"} |= "error"

# Recent logs with time range
{job="kubernetes-pods"} | json | line_format "{{.timestamp}} {{.level}} {{.message}}"
```

## 📊 Available Dashboards

The following dashboards are automatically installed:

- **Loki Overview** (ID: 12019): General Loki metrics and health
- **Loki Kubernetes** (ID: 12020): Kubernetes-specific log analysis
- **Kubernetes Pods**: Pod-level monitoring with Prometheus metrics

## 🔧 Configuration

### Storage Configuration

Loki is configured with:
- **Storage Type**: S3 (MinIO)
- **Bucket**: `loki-logs`
- **Retention**: 30 days
- **Compaction**: Enabled for long-term storage

### Log Collection

Promtail automatically collects:
- Kubernetes pod logs
- System logs (`/var/log/*`)
- Container logs (`/var/lib/docker/containers/*`)

### Resource Limits

- **Loki**: 1 CPU, 2GB RAM
- **MinIO**: 1 CPU, 1GB RAM
- **Promtail**: 500m CPU, 512MB RAM

## 🧠 AI-Powered Log Analysis Setup

For AI-powered log analysis, you can extend this setup with:

### 1. Vector Database Integration

```python
# Example: Log processing script for AI analysis
import requests
import chromadb
from sentence_transformers import SentenceTransformer
import json

# Initialize components
model = SentenceTransformer('all-MiniLM-L6-v2')
chroma_client = chromadb.Client()
collection = chroma_client.create_collection("logs")

# Fetch logs from Loki
def fetch_logs_from_loki(query, start_time, end_time):
    loki_url = "http://loki.logging.svc.cluster.local:3100"
    response = requests.get(f"{loki_url}/loki/api/v1/query_range", {
        "query": query,
        "start": start_time,
        "end": end_time
    })
    return response.json()

# Process and embed logs
def process_logs(logs_data):
    for log in logs_data['data']['result']:
        # Extract log content
        log_content = log['values'][0][1]
        
        # Generate embedding
        embedding = model.encode(log_content)
        
        # Store in vector DB
        collection.add(
            embeddings=[embedding.tolist()],
            documents=[log_content],
            metadatas=[{
                "timestamp": log['values'][0][0],
                "stream": log['stream'],
                "namespace": log['stream'].get('namespace', 'unknown')
            }]
        )

# Semantic search
def search_logs(query, n_results=10):
    query_embedding = model.encode(query)
    results = collection.query(
        query_embeddings=[query_embedding.tolist()],
        n_results=n_results
    )
    return results
```

### 2. Fluent Bit for Advanced Processing

For more advanced log processing, consider replacing Promtail with Fluent Bit:

```yaml
# fluent-bit-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: fluent-bit-config
data:
  fluent-bit.conf: |
    [SERVICE]
        Parsers_File    parsers.conf
        HTTP_Server     On
        HTTP_Listen     0.0.0.0
        HTTP_Port       2020

    [INPUT]
        Name              tail
        Tag               kube.*
        Path              /var/log/containers/*.log
        Parser            docker
        DB                /var/log/flb_kube.db
        Skip_Long_Lines   On
        Refresh_Interval  10

    [FILTER]
        Name                kubernetes
        Match               kube.*
        Kube_URL           https://kubernetes.default.svc:443
        Kube_CA_Path       /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
        Kube_Token_Path    /var/run/secrets/kubernetes.io/serviceaccount/token
        Merge_Log          On
        Merge_Log_Key      log_processed
        K8S-Logging.Parser On
        K8S-Logging.Exclude On

    [OUTPUT]
        Name        loki
        Match       kube.*
        Host        loki.logging.svc.cluster.local
        Port        3100
        Labels      job=fluentbit
        Label_Keys  $kubernetes['namespace_name'],$kubernetes['pod_name'],$kubernetes['container_name']
        Remove_Keys kubernetes,stream,time,tag

    [OUTPUT]
        Name        file
        Match       kube.*
        Path        /tmp/logs/
        Format      json
        Time_Key    @timestamp
```

### 3. Telegram Bot for Log Alerts

```python
# telegram_log_bot.py
import telegram
import asyncio
from datetime import datetime, timedelta

class LogAlertBot:
    def __init__(self, token, chat_id):
        self.bot = telegram.Bot(token=token)
        self.chat_id = chat_id
    
    async def send_log_alert(self, query, time_range="1h"):
        # Query Loki for recent errors
        loki_url = "http://loki.logging.svc.cluster.local:3100"
        end_time = datetime.now()
        start_time = end_time - timedelta(hours=1)
        
        response = requests.get(f"{loki_url}/loki/api/v1/query_range", {
            "query": query,
            "start": start_time.isoformat(),
            "end": end_time.isoformat()
        })
        
        logs = response.json()
        if logs['data']['result']:
            message = f"🚨 Log Alert ({time_range}):\n\n"
            for log in logs['data']['result'][:5]:  # Top 5 logs
                message += f"• {log['values'][0][1]}\n"
            
            await self.bot.send_message(chat_id=self.chat_id, text=message)

# Usage
bot = LogAlertBot("YOUR_BOT_TOKEN", "YOUR_CHAT_ID")
asyncio.run(bot.send_log_alert('{job="kubernetes-pods"} |= "error"'))
```

## 🔍 Useful LogQL Queries

### Basic Queries
```logql
# All application logs
{app="my-app"}

# Error logs across all namespaces
{job="kubernetes-pods"} |= "error"

# Specific time range
{job="kubernetes-pods"} [5m]

# Logs with specific labels
{namespace="monitoring", pod=~"prometheus.*"}
```

### Advanced Queries
```logql
# Rate of error logs per minute
rate({job="kubernetes-pods"} |= "error" [1m])

# Top 10 pods by log volume
topk(10, sum by (pod) (rate({job="kubernetes-pods"}[5m])))

# JSON parsing
{job="kubernetes-pods"} | json | level="error"

# Pattern matching
{job="kubernetes-pods"} |~ "(?i)error|exception|fail"
```

## 🛠 Troubleshooting

### Check Loki Status
```bash
# Check Loki pods
kubectl get pods -n logging -l app.kubernetes.io/name=loki

# Check Loki logs
kubectl logs -n logging -l app.kubernetes.io/name=loki

# Check MinIO status
kubectl get pods -n logging -l app.kubernetes.io/name=minio
```

### Verify Log Collection
```bash
# Check Promtail logs
kubectl logs -n logging -l app.kubernetes.io/name=promtail

# Test Loki API
curl -G -s "http://loki.logging.svc.cluster.local:3100/loki/api/v1/labels" | jq
```

### Common Issues

1. **No logs appearing**: Check Promtail configuration and Loki connectivity
2. **Storage issues**: Verify MinIO is running and accessible
3. **High memory usage**: Adjust resource limits in values files
4. **Slow queries**: Optimize LogQL queries and consider indexing

## 📈 Scaling Considerations

### Horizontal Scaling
- Loki supports horizontal scaling with multiple instances
- Use consistent hashing for log distribution
- Consider using external object storage (AWS S3, GCS)

### Performance Tuning
- Adjust chunk size and retention settings
- Use appropriate compression settings
- Monitor and tune resource limits

### Backup Strategy
- MinIO data is persisted to PVC
- Consider regular backups of MinIO data
- Implement log retention policies

## 🔐 Security Notes

- Default credentials are used for development
- Change MinIO credentials in production
- Consider enabling TLS for all services
- Implement proper RBAC for Kubernetes access
- Use secrets for sensitive configuration

## 📚 Additional Resources

- [Loki Documentation](https://grafana.com/docs/loki/latest/)
- [LogQL Reference](https://grafana.com/docs/loki/latest/logql/)
- [Promtail Configuration](https://grafana.com/docs/loki/latest/clients/promtail/)
- [Grafana Logs](https://grafana.com/docs/grafana/latest/explore/logs-integration/) 