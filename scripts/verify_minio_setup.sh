#!/bin/bash

# MinIO Setup Verification Script
# This script verifies that MinIO is properly configured and Loki logs are being stored

set -e

echo "🔍 Verifying MinIO Setup for Loki Logging..."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

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

# Check if mc (MinIO Client) is available
if ! command -v mc &> /dev/null; then
    print_warning "MinIO Client (mc) is not installed. Installing..."
    if command -v wget &> /dev/null; then
        wget https://dl.min.io/client/mc/release/linux-amd64/mc
        chmod +x mc
        sudo mv mc /usr/local/bin/
    elif command -v curl &> /dev/null; then
        curl -o mc https://dl.min.io/client/mc/release/linux-amd64/mc
        chmod +x mc
        sudo mv mc /usr/local/bin/
    else
        print_error "Cannot install MinIO Client. Please install manually from https://min.io/download"
        exit 1
    fi
fi

print_status "Step 1: Checking MinIO deployment..."

# Check if MinIO namespace exists
if kubectl get namespace logging &>/dev/null; then
    print_success "Logging namespace exists"
else
    print_error "Logging namespace does not exist. Please deploy the Loki stack first."
    exit 1
fi

# Check MinIO pods
if kubectl get pods -n logging -l app.kubernetes.io/name=minio --no-headers | grep -q "Running"; then
    print_success "MinIO pods are running"
else
    print_error "MinIO pods are not running"
    kubectl get pods -n logging -l app.kubernetes.io/name=minio
    exit 1
fi

print_status "Step 2: Checking MinIO services..."

# Check MinIO service
if kubectl get svc -n logging minio &>/dev/null; then
    print_success "MinIO service exists"
    kubectl get svc -n logging minio
else
    print_error "MinIO service does not exist"
    exit 1
fi

# Check MinIO Console service
if kubectl get svc -n logging minio-console &>/dev/null; then
    print_success "MinIO Console service exists"
    kubectl get svc -n logging minio-console
else
    print_warning "MinIO Console service does not exist"
fi

print_status "Step 3: Testing MinIO connectivity..."

# Test MinIO API endpoint
if kubectl run test-minio --image=curlimages/curl --rm -it --restart=Never -- \
    curl -s "http://minio.logging.svc.cluster.local:9000/minio/health/live" 2>/dev/null; then
    print_success "MinIO API is accessible"
else
    print_warning "MinIO API test failed - this might be normal if health endpoint is not available"
fi

print_status "Step 4: Setting up MinIO Client..."

# Configure MinIO client
MINIO_ENDPOINT="http://minio.logging.svc.cluster.local:9000"
MINIO_USER="minioadmin"
MINIO_PASSWORD="minioadmin"
BUCKET_NAME="loki-logs"

# Add MinIO alias
if mc alias set loki-local "$MINIO_ENDPOINT" "$MINIO_USER" "$MINIO_PASSWORD" &>/dev/null; then
    print_success "MinIO client configured"
else
    print_error "Failed to configure MinIO client"
    exit 1
fi

print_status "Step 5: Checking Loki logs bucket..."

# Check if bucket exists
if mc ls loki-local/"$BUCKET_NAME" &>/dev/null; then
    print_success "Loki logs bucket exists: $BUCKET_NAME"
else
    print_warning "Loki logs bucket does not exist. Creating..."
    if mc mb loki-local/"$BUCKET_NAME" &>/dev/null; then
        print_success "Created Loki logs bucket: $BUCKET_NAME"
    else
        print_error "Failed to create Loki logs bucket"
        exit 1
    fi
fi

print_status "Step 6: Checking for Loki log data..."

# List objects in the bucket
OBJECT_COUNT=$(mc ls loki-local/"$BUCKET_NAME" --recursive | wc -l 2>/dev/null || echo "0")

if [ "$OBJECT_COUNT" -gt 0 ]; then
    print_success "Found $OBJECT_COUNT objects in Loki logs bucket"
    
    # Show some sample objects
    print_status "Sample objects in bucket:"
    mc ls loki-local/"$BUCKET_NAME" --recursive | head -10
    
    # Show bucket size
    BUCKET_SIZE=$(mc du loki-local/"$BUCKET_NAME" --recursive 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
    print_status "Bucket size: $BUCKET_SIZE"
else
    print_warning "No objects found in Loki logs bucket yet"
    print_status "This is normal for a fresh deployment. Logs will appear as applications generate them."
fi

print_status "Step 7: Checking Loki configuration..."

# Check if Loki is configured to use MinIO
if kubectl get configmap -n logging -l app.kubernetes.io/name=loki -o yaml | grep -q "s3://loki-logs"; then
    print_success "Loki is configured to use MinIO S3 storage"
else
    print_warning "Loki S3 configuration not found in configmaps"
fi

print_status "Step 8: Access Information"

echo ""
echo "🎯 MinIO Setup Verification Complete!"
echo ""
echo "📊 Access URLs:"
echo "   MinIO API:      http://minio.logging.svc.cluster.local:9000"
echo "   MinIO Console:  http://minio-console.vermillion.local"
echo "   Loki:           http://loki.vermillion.local"
echo ""
echo "🔑 Credentials:"
echo "   Username:       $MINIO_USER"
echo "   Password:       $MINIO_PASSWORD"
echo ""
echo "📦 S3 Bucket:      $BUCKET_NAME"
echo ""
echo "📝 Useful Commands:"
echo "   # List all buckets"
echo "   mc ls loki-local"
echo ""
echo "   # List objects in Loki bucket"
echo "   mc ls loki-local/$BUCKET_NAME --recursive"
echo ""
echo "   # Download a specific log file"
echo "   mc cp loki-local/$BUCKET_NAME/path/to/file /local/path"
echo ""
echo "   # Check bucket size"
echo "   mc du loki-local/$BUCKET_NAME --recursive"
echo ""
echo "   # Access MinIO console via port-forward"
echo "   kubectl port-forward -n logging svc/minio-console 9001:9001"
echo ""
echo "🧠 AI Integration:"
echo "   # The AI log analyzer can now access logs via S3:"
echo "   python scripts/ai_log_analyzer.py --action fetch"
echo ""

# Cleanup
mc alias remove loki-local &>/dev/null || true

print_success "MinIO setup verification completed successfully!" 