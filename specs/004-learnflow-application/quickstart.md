# LearnFlow - 15-Minute Quick Start Guide

Get LearnFlow running locally on Minikube in just 15 minutes. This guide walks you through setting up the complete infrastructure and deploying the application.

**Estimated Time**: 15 minutes
**Prerequisites**: 15 minutes to install tools
**Total Setup**: ~30 minutes for first-time install

---

## Part 1: Prerequisites (5 minutes)

Install required tools. If you already have them, skip to Part 2.

### 1.1 Docker Desktop

Docker is required for Minikube to run containerized Kubernetes.

**macOS/Windows:**
```bash
# Download from https://www.docker.com/products/docker-desktop
# Install and start the application
docker --version
# Expected: Docker version 20.10+
```

**Linux:**
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io
sudo systemctl start docker
sudo systemctl enable docker
docker --version
```

### 1.2 Minikube

Local Kubernetes cluster.

```bash
# macOS (Homebrew)
brew install minikube

# Linux
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# Windows (Chocolatey)
choco install minikube

# Verify installation
minikube version
# Expected: minikube version: v1.30.0 or later
```

### 1.3 kubectl

Kubernetes command-line tool.

```bash
# macOS
brew install kubectl

# Linux
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Windows
choco install kubernetes-cli

# Verify installation
kubectl version --client --short
# Expected: Client Version: v1.27.0 or later
```

### 1.4 Dapr CLI

Distributed Application Runtime - manages service communication.

```bash
# macOS
brew install dapr/tap/dapr-cli

# Linux/Windows (Universal)
wget -q https://raw.githubusercontent.com/dapr/cli/master/install/install.sh -O - | /bin/bash

# Verify installation
dapr version
# Expected: CLI version: 1.12.0 or later
```

### 1.5 Helm

Kubernetes package manager for deploying Kafka and PostgreSQL.

```bash
# macOS
brew install helm

# Linux
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# Windows
choco install kubernetes-helm

# Verify installation
helm version --short
# Expected: v3.12.0 or later
```

### 1.6 Python 3.11+

Backend language.

```bash
# macOS
brew install python@3.11

# Linux
sudo apt-get install python3.11 python3.11-venv

# Windows
# Download from https://www.python.org/downloads/
# Select "Add Python to PATH" during installation

# Verify installation
python3 --version
# Expected: Python 3.11.0 or later
```

### 1.7 Node.js 18+

Frontend build tool.

```bash
# macOS
brew install node

# Linux
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install nodejs

# Windows
choco install nodejs

# Verify installation
node --version && npm --version
# Expected: v18.0.0 or later, npm 9.0.0 or later
```

**Verification Script:**
```bash
docker --version && \
minikube version && \
kubectl version --client --short && \
dapr version && \
helm version --short && \
python3 --version && \
node --version && \
echo "✅ All tools installed!"
```

---

## Part 2: Infrastructure Setup (5 minutes)

Use CAPS playbooks to set up Kubernetes and backing services.

### 2.1 Start Minikube (2 minutes)

Create a local Kubernetes cluster with 4 CPU and 8GB RAM.

```bash
# Delete any existing cluster (clean slate)
minikube delete 2>/dev/null || echo "No existing cluster"

# Start Minikube with LearnFlow configuration
minikube start \
  --cpus=4 \
  --memory=8192 \
  --disk-size=20g \
  --driver=docker \
  --kubernetes-version=v1.27.0

# Wait for startup to complete (~2 minutes)
kubectl cluster-info
# Expected: Kubernetes control plane is running at https://...
```

### 2.2 Deploy Dapr Service Mesh (1 minute)

Enable inter-service communication and state management.

```bash
# Initialize Dapr on Kubernetes
dapr init --kubernetes --wait --timeout 300

# Verify Dapr installation
dapr status -k
# Expected: All components show HEALTHY status

# Enable port-forward to Dapr dashboard (optional, for monitoring)
kubectl port-forward -n dapr-system svc/dapr-dashboard 8080:8080 &
# Dashboard at http://localhost:8080
```

### 2.3 Deploy Kafka (1 minute)

Message broker for event streaming.

```bash
# Add Bitnami Helm repository
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

# Create kafka namespace
kubectl create namespace kafka

# Deploy Kafka cluster (3 brokers)
helm install kafka bitnami/kafka \
  --namespace kafka \
  --set replicaCount=1 \
  --set persistence.enabled=false \
  --set zookeeper.enabled=true \
  --set zookeeper.replicaCount=1 \
  --wait --timeout=300s

# Verify Kafka deployment
kubectl get pods -n kafka
# Expected: kafka-0 and zookeeper-0 running
```

### 2.4 Deploy PostgreSQL (1 minute)

Primary data store for students, courses, and submissions.

```bash
# Create database namespace
kubectl create namespace database

# Generate secure PostgreSQL password
PG_PASSWORD=$(openssl rand -base64 32 | tr -d "=+/" | cut -c1-25)
echo "PostgreSQL Password: $PG_PASSWORD"

# Deploy PostgreSQL
helm install postgresql bitnami/postgresql \
  --namespace database \
  --set auth.postgresPassword=$PG_PASSWORD \
  --set primary.persistence.enabled=false \
  --set readReplicas.replicaCount=0 \
  --wait --timeout=300s

# Verify PostgreSQL deployment
kubectl get pods -n database
# Expected: postgresql-0 running
```

### 2.5 Verify Infrastructure (0 minutes - runs in background)

All services should be running and ready.

```bash
# Check all namespaces
kubectl get namespaces

# Check all pods status
kubectl get pods --all-namespaces | grep -E "Running|Pending|Error"

# Quick health check script
echo "=== Kubernetes ===" && \
kubectl cluster-info | head -2 && \
echo "✓ Cluster running" && \
\
echo -e "\n=== Dapr ===" && \
dapr status -k | grep HEALTHY | wc -l && \
echo "✓ Dapr healthy" && \
\
echo -e "\n=== Kafka ===" && \
kubectl get pods -n kafka | grep Running && \
echo "✓ Kafka running" && \
\
echo -e "\n=== PostgreSQL ===" && \
kubectl get pods -n database | grep Running && \
echo "✓ PostgreSQL running"
```

---

## Part 3: Backend Deployment (3 minutes)

Deploy the LearnFlow Python FastAPI backend.

### 3.1 Clone Repository and Setup

```bash
# Clone the repository (if not already done)
cd ~/projects
git clone https://github.com/muhammadsami987123/Hackathon-III.git
cd Hackathon-III

# Create Python virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

### 3.2 Install Python Dependencies

```bash
# Install backend dependencies
pip install --upgrade pip
pip install fastapi uvicorn python-multipart aiohttp pydantic psycopg2-binary kafka-python dapr

# List installed packages
pip freeze | grep -E "fastapi|dapr|psycopg2"
```

### 3.3 Build and Deploy Backend

```bash
# Build Docker image for backend (from repo root)
docker build -t learnflow-api:latest ./learnflow-app/backend

# Load image into Minikube
minikube image load learnflow-api:latest

# Create learnflow namespace
kubectl create namespace learnflow

# Deploy backend (using pre-configured manifest)
kubectl apply -f ./learnflow-app/k8s/backend-deployment.yaml

# Wait for backend pod to be ready
kubectl wait --for=condition=Ready pods -l app=learnflow-api -n learnflow --timeout=60s

# Port-forward to access locally
kubectl port-forward -n learnflow svc/learnflow-api 8000:8000 &
echo "Backend API available at http://localhost:8000"
```

### 3.4 Verify Backend Health

```bash
# Check backend pod status
kubectl get pods -n learnflow
# Expected: learnflow-api-xxxxx with 2/2 Ready (API + Dapr sidecar)

# Test API health endpoint
curl -s http://localhost:8000/health | jq .
# Expected: {"status": "healthy"}
```

---

## Part 4: Frontend Deployment (2 minutes)

Deploy the LearnFlow Next.js frontend.

### 4.1 Install Frontend Dependencies

```bash
# Navigate to frontend directory
cd learnflow-app/frontend

# Install npm dependencies
npm install

# Check installation
npm list next react
```

### 4.2 Build and Deploy Frontend

```bash
# Build Next.js application
npm run build

# Build Docker image for frontend
docker build -t learnflow-web:latest .

# Load image into Minikube
minikube image load learnflow-web:latest

# Deploy frontend (from repo root)
cd ../..
kubectl apply -f ./learnflow-app/k8s/frontend-deployment.yaml

# Wait for frontend pod to be ready
kubectl wait --for=condition=Ready pods -l app=learnflow-web -n learnflow --timeout=60s

# Port-forward to access locally
kubectl port-forward -n learnflow svc/learnflow-web 3000:3000 &
echo "Frontend available at http://localhost:3000"
```

### 4.3 Verify Frontend Health

```bash
# Check frontend pod status
kubectl get pods -n learnflow
# Expected: learnflow-web-xxxxx with 1/1 Ready

# Test frontend health
curl -s http://localhost:3000 | head -20
# Expected: HTML page content
```

---

## Part 5: Verification & Testing (1 minute)

Confirm the full LearnFlow system is working.

### 5.1 Health Checks

```bash
# Check all services running
kubectl get svc -n learnflow
# Expected:
# learnflow-api      ClusterIP  10.x.x.x  8000/TCP
# learnflow-web      ClusterIP  10.x.x.x  3000/TCP

# Verify API connectivity
curl -s http://localhost:8000/health | jq .
# Expected: {"status": "healthy"}

# Verify Frontend connectivity
curl -s http://localhost:3000 -o /dev/null -w "%{http_code}\n"
# Expected: 200
```

### 5.2 Create Test Student Account

```bash
# Register a student via API
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@test.com",
    "name": "Test Student",
    "password": "SecurePassword123!",
    "role": "student"
  }'

# Expected response:
# {"id": "uuid-here", "email": "student@test.com", "name": "Test Student", "role": "student"}

# Login and get token
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "student@test.com",
    "password": "SecurePassword123!"
  }'

# Expected response includes access_token
```

### 5.3 Test Code Sandbox Execution

```bash
# Get auth token (replace with actual token from login response)
TOKEN="your-auth-token-here"

# Submit code for execution
curl -X POST http://localhost:8000/sandbox/execute \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "code": "print(\"Hello from LearnFlow!\")\nx = 5\nprint(f\"x = {x}\")",
    "language": "python"
  }'

# Expected response:
# {"output": "Hello from LearnFlow!\nx = 5", "status": "success", "execution_time": 0.15}
```

### 5.4 Test AI Tutor Chat

```bash
# Send a question to AI tutor
curl -X POST http://localhost:8000/tutor/chat \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $TOKEN" \
  -d '{
    "message": "How do variables work in Python?",
    "topic": "variables",
    "agent_type": "concepts"
  }'

# Expected response:
# {"response": "Variables are containers that store data values...", "confidence": 0.95}
```

### 5.5 Teacher Dashboard Access

```bash
# Create a teacher account
curl -X POST http://localhost:8000/auth/register \
  -H "Content-Type: application/json" \
  -d '{
    "email": "teacher@test.com",
    "name": "Test Teacher",
    "password": "SecurePassword123!",
    "role": "teacher"
  }'

# Access teacher dashboard in browser at http://localhost:3000/teacher
```

---

## Complete Verification Script

Run this script to check everything at once:

```bash
#!/bin/bash

echo "=== LearnFlow Quick Start Verification ==="
echo ""

# Check Docker
echo -n "Docker: "
docker ps >/dev/null 2>&1 && echo "✅ Running" || echo "❌ Not running"

# Check Minikube
echo -n "Minikube: "
minikube status | grep -q "Running" && echo "✅ Running" || echo "❌ Not running"

# Check Kubernetes
echo -n "Kubernetes: "
kubectl cluster-info 2>/dev/null | grep -q "running" && echo "✅ Running" || echo "❌ Not running"

# Check Dapr
echo -n "Dapr: "
dapr status -k 2>/dev/null | grep -q "HEALTHY" && echo "✅ Healthy" || echo "❌ Not healthy"

# Check Kafka
echo -n "Kafka: "
kubectl get pods -n kafka 2>/dev/null | grep -q "Running" && echo "✅ Running" || echo "❌ Not running"

# Check PostgreSQL
echo -n "PostgreSQL: "
kubectl get pods -n database 2>/dev/null | grep -q "Running" && echo "✅ Running" || echo "❌ Not running"

# Check LearnFlow API
echo -n "LearnFlow API: "
curl -s http://localhost:8000/health 2>/dev/null | grep -q "healthy" && echo "✅ Running" || echo "❌ Not running"

# Check LearnFlow Web
echo -n "LearnFlow Web: "
curl -s http://localhost:3000 2>/dev/null | grep -q "html" && echo "✅ Running" || echo "❌ Not running"

echo ""
echo "=== Setup Complete ==="
echo ""
echo "Access LearnFlow:"
echo "  Frontend: http://localhost:3000"
echo "  API Docs: http://localhost:8000/docs"
echo "  Dapr Dashboard: http://localhost:8080"
```

---

## Troubleshooting

### Minikube fails to start

**Problem**: `Error: Insufficient memory` or `Error: Insufficient CPUs`

**Solution**:
```bash
# Check available resources
free -h  # Linux/macOS
# systeminfo | findstr /C:"Total Physical Memory"  # Windows

# Reduce resource allocation
minikube start --cpus=2 --memory=4096

# Or delete and restart
minikube delete
minikube start --cpus=4 --memory=8192
```

### Pods stuck in Pending

**Problem**: Pods not transitioning to Running

**Solution**:
```bash
# Check pod events
kubectl describe pod <pod-name> -n <namespace>

# Check node resources
kubectl top nodes
kubectl top pods --all-namespaces

# Restart Minikube if resources exhausted
minikube stop
minikube start
```

### Port forwarding not working

**Problem**: `Connection refused` when accessing localhost:8000 or :3000

**Solution**:
```bash
# Kill all existing port forwards
pkill -f "port-forward"

# Re-establish port forwards
kubectl port-forward -n learnflow svc/learnflow-api 8000:8000 &
kubectl port-forward -n learnflow svc/learnflow-web 3000:3000 &

# Verify ports are listening
netstat -tlnp | grep -E "8000|3000"  # Linux/macOS
# netstat -ano | findstr "8000"  # Windows
```

### Database connection errors

**Problem**: Backend can't connect to PostgreSQL

**Solution**:
```bash
# Get PostgreSQL service details
kubectl get svc -n database

# Test connectivity from backend pod
kubectl exec -it <backend-pod> -n learnflow -- \
  psql postgresql://postgres:$PG_PASSWORD@postgresql.database:5432/learnflow

# Check PostgreSQL logs
kubectl logs -n database postgresql-0
```

### Kafka connection errors

**Problem**: Backend services can't reach Kafka

**Solution**:
```bash
# Verify Kafka is running
kubectl get pods -n kafka

# Check Kafka broker logs
kubectl logs -n kafka kafka-0

# Test Kafka connectivity from pod
kubectl exec -it kafka-0 -n kafka -- \
  kafka-topics.sh --list --bootstrap-server localhost:9092
```

---

## Next Steps

After verification:

1. **Create a classroom**: Use teacher dashboard to set up a Python course
2. **Enroll students**: Add student accounts to your classroom
3. **Assign exercises**: Create or select exercises for students
4. **Monitor progress**: View student progress, code submissions, and struggle alerts
5. **Generate content**: Use Exercise Agent to create remedial exercises

---

## Cleanup & Stopping

Stop the system without deleting data:

```bash
# Stop all port forwards
pkill -f "port-forward"

# Stop Minikube (preserves state)
minikube stop

# Restart later with:
minikube start
```

Full cleanup (delete all data):

```bash
# Stop port forwards
pkill -f "port-forward"

# Delete Minikube cluster
minikube delete

# Delete LearnFlow app directories (if needed)
rm -rf learnflow-app/
rm -rf .specify/
```

---

## Resources

- **Minikube Docs**: https://minikube.sigs.k8s.io/docs/
- **Dapr Docs**: https://docs.dapr.io/
- **Kafka Docs**: https://kafka.apache.org/documentation/
- **PostgreSQL Docs**: https://www.postgresql.org/docs/
- **FastAPI Docs**: https://fastapi.tiangolo.com/
- **Next.js Docs**: https://nextjs.org/docs

---

**Last Updated**: 2025-12-22
**Maintenance**: Keep tools updated via package managers (brew, apt, choco, pip, npm)
