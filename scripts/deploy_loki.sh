#!/bin/bash

# Loki Logging Stack Deployment Script
# This script helps deploy and verify the Loki logging infrastructure

set -e

echo "🚀 Deploying Loki Logging Stack..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed or not in PATH"
    exit 1
fi

# Check if terraform is available
if ! command -v terraform &> /dev/null; then
    print_error "terraform is not installed or not in PATH"
    exit 1
fi

# Function to wait for pods to be ready
wait_for_pods() {
    local namespace=$1
    local label_selector=$2
    local timeout=${3:-300}  # Default 5 minutes
    
    print_status "Waiting for pods in namespace '$namespace' with selector '$label_selector'..."
    
    local elapsed=0
    while [ $elapsed -lt $timeout ]; do
        local ready_pods=$(kubectl get pods -n "$namespace" -l "$label_selector" --no-headers | grep -c "Running\|Completed" || true)
        local total_pods=$(kubectl get pods -n "$namespace" -l "$label_selector" --no-headers | wc -l || true)
        
        if [ "$ready_pods" -eq "$total_pods" ] && [ "$total_pods" -gt 0 ]; then
            print_success "All pods are ready in namespace '$namespace'"
            return 0
        fi
        
        print_status "Waiting... ($ready_pods/$total_pods pods ready)"
        sleep 10
        elapsed=$((elapsed + 10))
    done
    
    print_error "Timeout waiting for pods in namespace '$namespace'"
    return 1
}

# Function to check service endpoints
check_service_endpoints() {
    local namespace=$1
    local service_name=$2
    local port=$3
    
    print_status "Checking service endpoint: $service_name.$namespace.svc.cluster.local:$port"
    
    # Try to connect to the service
    if kubectl run test-connection --image=busybox --rm -it --restart=Never -- \
        wget -qO- --timeout=10 "http://$service_name.$namespace.svc.cluster.local:$port/ready" 2>/dev/null || \
        kubectl run test-connection --image=busybox --rm -it --restart=Never -- \
        wget -qO- --timeout=10 "http://$service_name.$namespace.svc.cluster.local:$port" 2>/dev/null; then
        print_success "Service $service_name is accessible"
        return 0
    else
        print_warning "Service $service_name is not accessible yet"
        return 1
    fi
}

# Step 1: Apply Terraform configuration
print_status "Step 1: Applying Terraform configuration..."
cd "$(dirname "$0")/.."

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    print_status "Initializing Terraform..."
    terraform init
fi

# Plan the deployment
print_status "Planning Terraform deployment..."
terraform plan -out=tfplan

# Apply the configuration
print_status "Applying Terraform configuration..."
terraform apply tfplan

print_success "Terraform configuration applied successfully"

# Step 2: Wait for pods to be ready
print_status "Step 2: Waiting for pods to be ready..."

# Wait for Loki namespace pods
wait_for_pods "logging" "app.kubernetes.io/name=loki"
wait_for_pods "logging" "app.kubernetes.io/name=minio"
wait_for_pods "logging" "app.kubernetes.io/name=promtail"

# Wait for monitoring namespace pods (if they exist)
if kubectl get namespace monitoring &>/dev/null; then
    wait_for_pods "monitoring" "app.kubernetes.io/name=grafana"
fi

# Step 3: Verify services
print_status "Step 3: Verifying services..."

# Check Loki service
check_service_endpoints "logging" "loki" "3100"

# Check MinIO service
check_service_endpoints "logging" "minio" "9000"

# Step 4: Test Loki API
print_status "Step 4: Testing Loki API..."

# Wait a bit for Loki to be fully ready
sleep 30

# Test Loki labels endpoint
if kubectl run test-loki --image=curlimages/curl --rm -it --restart=Never -- \
    curl -s "http://loki.logging.svc.cluster.local:3100/loki/api/v1/labels" | grep -q "status"; then
    print_success "Loki API is responding"
else
    print_warning "Loki API test failed - this might be normal if no logs are present yet"
fi

# Step 5: Display access information
print_status "Step 5: Access Information"

echo ""
echo "🎯 Loki Logging Stack Deployment Complete!"
echo ""
echo "📊 Access URLs:"
echo "   Grafana:     http://grafana.vermillion.local (admin/admin)"
echo "   Loki:        http://loki.vermillion.local"
echo "   MinIO:       http://minio.logging.svc.cluster.local:9000"
echo ""
echo "🔑 Default Credentials:"
echo "   MinIO:       minioadmin/minioadmin"
echo "   Grafana:     admin/admin"
echo ""
echo "📝 Useful Commands:"
echo "   # View Loki logs"
echo "   kubectl logs -n logging -l app.kubernetes.io/name=loki"
echo ""
echo "   # View Promtail logs"
echo "   kubectl logs -n logging -l app.kubernetes.io/name=promtail"
echo ""
echo "   # Check Loki metrics"
echo "   kubectl port-forward -n logging svc/loki 3100:3100"
echo ""
echo "   # Access MinIO console"
echo "   kubectl port-forward -n logging svc/minio 9001:9001"
echo ""
echo "🧠 AI Integration:"
echo "   # Install AI log analyzer dependencies"
echo "   pip install -r scripts/requirements.txt"
echo ""
echo "   # Fetch and process logs for AI analysis"
echo "   python scripts/ai_log_analyzer.py --action fetch"
echo ""
echo "   # Search logs semantically"
echo "   python scripts/ai_log_analyzer.py --action search --search-query 'error in database connection'"
echo ""
echo "   # Analyze log patterns"
echo "   python scripts/ai_log_analyzer.py --action analyze --time-range 24h"
echo ""

# Step 6: Optional - Show current log streams
print_status "Step 6: Checking for log streams..."

# Wait a bit more for logs to start flowing
sleep 60

# Check if there are any log streams
if kubectl run check-streams --image=curlimages/curl --rm -it --restart=Never -- \
    curl -s "http://loki.logging.svc.cluster.local:3100/loki/api/v1/labels" | grep -q "values"; then
    print_success "Log streams are being collected"
    print_status "Available log streams:"
    kubectl run show-streams --image=curlimages/curl --rm -it --restart=Never -- \
        curl -s "http://loki.logging.svc.cluster.local:3100/loki/api/v1/labels" | jq '.data[]' 2>/dev/null || \
        kubectl run show-streams --image=curlimages/curl --rm -it --restart=Never -- \
        curl -s "http://loki.logging.svc.cluster.local:3100/loki/api/v1/labels"
else
    print_warning "No log streams found yet - this is normal for a fresh deployment"
    print_status "Logs will start appearing as applications generate them"
fi

print_success "Loki logging stack deployment completed successfully!"
echo ""
echo "📚 Next Steps:"
echo "   1. Access Grafana and explore logs using LogQL queries"
echo "   2. Set up custom dashboards for your applications"
echo "   3. Configure log retention policies in Loki"
echo "   4. Set up AI-powered log analysis using the provided scripts"
echo "   5. Consider setting up alerting rules for critical errors"
echo "" 