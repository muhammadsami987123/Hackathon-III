---
title: FastAPI Dapr Service
description: Create FastAPI microservice with Dapr sidecar on Kubernetes for state management and service invocation
version: 1.0.0
category: backend
tags:
  - fastapi
  - python
  - dapr
  - kubernetes
  - microservices
difficulty: advanced
estimated_time: 30
allowed_tools:
  - bash
  - kubectl
  - docker
  - python
  - helm
prerequisites:
  - kubernetes_cluster_running
  - kubectl_configured
  - dapr_installed_on_cluster
  - docker_daemon_running
dependencies:
  - postgresql-k8s-setup
skip_conditions:
  - fastapi_service_already_deployed
---

# FastAPI Dapr Service

Create and deploy a FastAPI microservice with Dapr sidecar on Kubernetes. This playbook demonstrates building a RESTful API service with Dapr for state management, service-to-service invocation, and pub/sub messaging.

## Prerequisites

Before starting, verify:

**Required Software:**
```bash
# Check Kubernetes cluster
kubectl cluster-info

# Check kubectl version
kubectl version --client

# Check Dapr CLI installed
dapr --version
# Expected: CLI version: 1.12.0 or later

# Check Dapr on cluster
dapr status -k
# Expected: dapr-operator, dapr-sidecar-injector, dapr-sentry running

# Check Docker daemon
docker info > /dev/null 2>&1 && echo "✓ Docker running" || echo "✗ Docker not running"
```

**Required Environment:**
- Kubernetes cluster with Dapr installed
- Docker for building images (or access to container registry)
- kubectl configured
- Python 3.11+ (for local development)

**Resource Requirements:**
- FastAPI app: 256MB RAM, 100m CPU
- Dapr sidecar: 128MB RAM, 50m CPU
- Total: ~400MB RAM per pod

## Instructions

### Step 1: Create Project Structure

**Objective:** Set up FastAPI project directory structure

**Commands:**
```bash
# Create project directory
mkdir -p fastapi-dapr-app
cd fastapi-dapr-app

# Create application structure
mkdir -p app k8s

# Create main application file
cat > app/main.py <<'EOF'
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import httpx
import os

app = FastAPI(title="FastAPI Dapr Service")

# Dapr sidecar URL
DAPR_URL = os.getenv("DAPR_HTTP_ENDPOINT", "http://localhost:3500")
STATE_STORE_NAME = "statestore"

class Item(BaseModel):
    id: str
    name: str
    description: str = None

@app.get("/")
async def root():
    return {"message": "FastAPI Dapr Service", "version": "1.0.0"}

@app.get("/health")
async def health():
    return {"status": "healthy"}

@app.post("/items/{item_id}")
async def create_item(item_id: str, item: Item):
    # Save to Dapr state store
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"{DAPR_URL}/v1.0/state/{STATE_STORE_NAME}",
            json=[{"key": item_id, "value": item.dict()}]
        )
    if response.status_code != 204:
        raise HTTPException(status_code=500, detail="Failed to save item")
    return {"message": f"Item {item_id} created", "item": item}

@app.get("/items/{item_id}")
async def get_item(item_id: str):
    # Get from Dapr state store
    async with httpx.AsyncClient() as client:
        response = await client.get(
            f"{DAPR_URL}/v1.0/state/{STATE_STORE_NAME}/{item_id}"
        )
    if response.status_code == 204:
        raise HTTPException(status_code=404, detail="Item not found")
    return response.json()
EOF

# Create requirements file
cat > app/requirements.txt <<'EOF'
fastapi==0.104.1
uvicorn[standard]==0.24.0
httpx==0.25.2
pydantic==2.5.2
EOF

echo "✓ Project structure created"
```

**Expected Output:**
```
✓ Project structure created
```

**Success Criteria:**
- [ ] Project directory `fastapi-dapr-app` created
- [ ] Application file `app/main.py` created
- [ ] Requirements file `app/requirements.txt` created

---

### Step 2: Create Dockerfile

**Objective:** Create Docker image for FastAPI application

**Commands:**
```bash
# Create Dockerfile
cat > Dockerfile <<'EOF'
FROM python:3.11-slim

WORKDIR /app

# Install dependencies
COPY app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY app/ .

# Expose port
EXPOSE 8000

# Run application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
EOF

echo "✓ Dockerfile created"
```

**Expected Output:**
```
✓ Dockerfile created
```

**Success Criteria:**
- [ ] Dockerfile created
- [ ] Uses Python 3.11 slim image
- [ ] Exposes port 8000

---

### Step 3: Build Docker Image

**Objective:** Build and tag Docker image for deployment

**Commands:**
```bash
# Build Docker image
docker build -t fastapi-dapr-service:1.0.0 .

# Tag for local registry (Minikube)
docker tag fastapi-dapr-service:1.0.0 localhost:5000/fastapi-dapr-service:1.0.0

# Verify image
docker images | grep fastapi-dapr-service
```

**Expected Output:**
```
[+] Building 45.2s (10/10) FINISHED
 => [internal] load build definition
 => => transferring dockerfile
 ...
Successfully built abc123def456
Successfully tagged fastapi-dapr-service:1.0.0

fastapi-dapr-service   1.0.0    abc123def456   10 seconds ago   200MB
```

**Success Criteria:**
- [ ] Docker image built successfully
- [ ] Image tagged with version 1.0.0
- [ ] Image size reasonable (~200MB)

---

### Step 4: Create Kubernetes Manifests

**Objective:** Create Deployment and Service manifests with Dapr annotations

**Commands:**
```bash
# Create deployment manifest with Dapr sidecar
cat > k8s/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastapi-dapr-service
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: fastapi-dapr-service
  template:
    metadata:
      labels:
        app: fastapi-dapr-service
      annotations:
        dapr.io/enabled: "true"
        dapr.io/app-id: "fastapi-service"
        dapr.io/app-port: "8000"
        dapr.io/enable-api-logging: "true"
    spec:
      containers:
      - name: fastapi
        image: fastapi-dapr-service:1.0.0
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 8000
        env:
        - name: DAPR_HTTP_ENDPOINT
          value: "http://localhost:3500"
        resources:
          requests:
            memory: "256Mi"
            cpu: "100m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: fastapi-dapr-service
  namespace: default
spec:
  selector:
    app: fastapi-dapr-service
  ports:
  - protocol: TCP
    port: 80
    targetPort: 8000
  type: ClusterIP
EOF

# Create Dapr state store component
cat > k8s/statestore.yaml <<'EOF'
apiVersion: dapr.io/v1alpha1
kind: Component
metadata:
  name: statestore
  namespace: default
spec:
  type: state.in-memory
  version: v1
  metadata: []
EOF

echo "✓ Kubernetes manifests created"
```

**Expected Output:**
```
✓ Kubernetes manifests created
```

**Success Criteria:**
- [ ] Deployment manifest created with Dapr annotations
- [ ] Service manifest created
- [ ] State store component created

---

### Step 5: Deploy to Kubernetes

**Objective:** Deploy FastAPI service with Dapr sidecar to cluster

**Commands:**
```bash
# Load image to Minikube (if using Minikube)
if command -v minikube &> /dev/null; then
    minikube image load fastapi-dapr-service:1.0.0
fi

# Apply Dapr component
kubectl apply -f k8s/statestore.yaml

# Apply deployment and service
kubectl apply -f k8s/deployment.yaml

# Wait for deployment
kubectl wait --for=condition=available deployment/fastapi-dapr-service --timeout=120s

# Check pods
kubectl get pods -l app=fastapi-dapr-service
```

**Expected Output:**
```
component.dapr.io/statestore created
deployment.apps/fastapi-dapr-service created
service/fastapi-dapr-service created

deployment.apps/fastapi-dapr-service condition met

NAME                                    READY   STATUS    RESTARTS   AGE
fastapi-dapr-service-abc123-xyz         2/2     Running   0          30s
```

**Success Criteria:**
- [ ] Dapr component created
- [ ] Deployment created successfully
- [ ] Service created
- [ ] Pod shows 2/2 containers (FastAPI + Dapr sidecar)

---

### Step 6: Test Service Health

**Objective:** Verify FastAPI service is healthy and responsive

**Commands:**
```bash
# Port forward to service
kubectl port-forward svc/fastapi-dapr-service 8080:80 &
PF_PID=$!
sleep 3

# Test root endpoint
curl -s http://localhost:8080/ | jq .

# Test health endpoint
curl -s http://localhost:8080/health | jq .

# Kill port-forward
kill $PF_PID 2>/dev/null
```

**Expected Output:**
```
{
  "message": "FastAPI Dapr Service",
  "version": "1.0.0"
}

{
  "status": "healthy"
}
```

**Success Criteria:**
- [ ] Root endpoint returns correct message
- [ ] Health endpoint returns healthy status
- [ ] No connection errors

---

### Step 7: Test Dapr State Management

**Objective:** Test creating and retrieving items via Dapr state store

**Commands:**
```bash
# Port forward again
kubectl port-forward svc/fastapi-dapr-service 8080:80 &
PF_PID=$!
sleep 3

# Create item
curl -X POST http://localhost:8080/items/item1 \
  -H "Content-Type: application/json" \
  -d '{"id":"item1","name":"Test Item","description":"This is a test"}' \
  | jq .

# Retrieve item
curl -s http://localhost:8080/items/item1 | jq .

# Kill port-forward
kill $PF_PID 2>/dev/null
```

**Expected Output:**
```
{
  "message": "Item item1 created",
  "item": {
    "id": "item1",
    "name": "Test Item",
    "description": "This is a test"
  }
}

{
  "id": "item1",
  "name": "Test Item",
  "description": "This is a test"
}
```

**Success Criteria:**
- [ ] Item created successfully
- [ ] Item retrieved from state store
- [ ] Data matches what was sent

---

### Step 8: Verify Dapr Sidecar

**Objective:** Confirm Dapr sidecar is running and healthy

**Commands:**
```bash
# Get pod name
POD_NAME=$(kubectl get pod -l app=fastapi-dapr-service -o jsonpath="{.items[0].metadata.name}")

# Check containers in pod
kubectl get pod $POD_NAME -o jsonpath='{.spec.containers[*].name}'
echo ""

# Check Dapr sidecar logs
kubectl logs $POD_NAME -c daprd --tail=20
```

**Expected Output:**
```
fastapi daprd

time="2025-12-19T19:55:00Z" level=info msg="dapr initialized. Status: Running."
time="2025-12-19T19:55:00Z" level=info msg="application discovered on port 8000"
time="2025-12-19T19:55:00Z" level=info msg="application protocol: http"
```

**Success Criteria:**
- [ ] Pod has 2 containers (fastapi + daprd)
- [ ] Dapr sidecar initialized successfully
- [ ] Application port discovered (8000)

## Validation

Success criteria (all must pass):

- [ ] **Deployment Exists:** `kubectl get deployment fastapi-dapr-service` shows READY 1/1
- [ ] **Service Exists:** `kubectl get svc fastapi-dapr-service` shows ClusterIP
- [ ] **Pod Running:** `kubectl get pods -l app=fastapi-dapr-service` shows 2/2 Running
- [ ] **Health Check:** curl to /health returns `{"status": "healthy"}`
- [ ] **State Management:** Can create and retrieve items via API
- [ ] **Dapr Sidecar:** daprd container running and initialized

**Quick Validation Script:**
```bash
kubectl get deployment fastapi-dapr-service && \
  kubectl get svc fastapi-dapr-service && \
  [[ $(kubectl get pods -l app=fastapi-dapr-service -o jsonpath='{.items[0].status.containerStatuses[*].ready}' | tr ' ' '\n' | grep -c true) -eq 2 ]] && \
  echo "✅ All validation checks passed!" || \
  echo "❌ Some validation checks failed"
```

## Troubleshooting

**Problem:** Pod shows 1/2 containers ready
**Symptoms:** Deployment stuck with READY showing 0/1 or pod shows 1/2
**Root Cause:** Dapr sidecar failed to inject or FastAPI app not starting
**Check:**
```bash
POD_NAME=$(kubectl get pod -l app=fastapi-dapr-service -o jsonpath="{.items[0].metadata.name}")
kubectl describe pod $POD_NAME
kubectl logs $POD_NAME -c fastapi
kubectl logs $POD_NAME -c daprd
```
**Fix:**
```bash
# Verify Dapr is installed on cluster
dapr status -k

# Check Dapr annotations in deployment
kubectl get deployment fastapi-dapr-service -o yaml | grep -A 5 annotations

# Restart deployment
kubectl rollout restart deployment fastapi-dapr-service
```

---

**Problem:** Image pull error
**Symptoms:** Pod shows `ImagePullBackOff` or `ErrImagePull`
**Root Cause:** Image not available in cluster (Minikube)
**Check:**
```bash
kubectl describe pod -l app=fastapi-dapr-service | grep -A 5 "Failed to pull image"
```
**Fix:**
```bash
# Load image to Minikube
minikube image load fastapi-dapr-service:1.0.0

# Or use imagePullPolicy: Never
kubectl patch deployment fastapi-dapr-service -p '{"spec":{"template":{"spec":{"containers":[{"name":"fastapi","imagePullPolicy":"Never"}]}}}}'
```

---

**Problem:** State store not working
**Symptoms:** API returns 500 error when creating/retrieving items
**Root Cause:** Dapr component not configured or sidecar can't connect
**Check:**
```bash
kubectl get components
kubectl describe component statestore
kubectl logs $POD_NAME -c daprd | grep statestore
```
**Fix:**
```bash
# Reapply state store component
kubectl apply -f k8s/statestore.yaml

# Restart deployment to reload component
kubectl rollout restart deployment fastapi-dapr-service
```

## Notes & References

**Important Considerations:**
- Dapr sidecar adds ~50-100ms latency per request
- In-memory state store loses data on pod restart (use Redis/PostgreSQL for production)
- Service-to-service calls use Dapr service invocation for retries and tracing

**Performance:**
- Execution time: 25-30 minutes (includes Docker build)
- Resource usage: ~400MB RAM per pod, 150m CPU
- Network bandwidth: ~300MB for images

**Security:**
- No authentication configured (add API keys or OAuth)
- Dapr mTLS enabled by default between sidecars
- State store is in-memory (no encryption at rest)

**Production Considerations:**
- Use persistent state store (Redis, PostgreSQL, Azure Cosmos DB)
- Enable Dapr observability (tracing, metrics)
- Configure resource limits
- Add horizontal pod autoscaling
- Use Ingress for external access

**Related Playbooks:**
- `postgresql-k8s-setup` - Database backend for state
- `kafka-k8s-setup` - Message broker for pub/sub

**External References:**
- [Dapr Documentation](https://docs.dapr.io/)
- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Dapr State Management](https://docs.dapr.io/developing-applications/building-blocks/state-management/)

## Rollback Instructions

### Step 1: Delete Deployment and Service
```bash
kubectl delete -f k8s/deployment.yaml
```

### Step 2: Delete Dapr Component
```bash
kubectl delete -f k8s/statestore.yaml
```

### Step 3: Remove Docker Image
```bash
docker rmi fastapi-dapr-service:1.0.0
```

### Step 4: Cleanup Project Directory
```bash
cd ..
rm -rf fastapi-dapr-app
```

## Next Steps

1. **Add Database Integration**: Use PostgreSQL state store instead of in-memory
2. **Enable Pub/Sub**: Subscribe to Kafka topics via Dapr
3. **Service Invocation**: Call other Dapr-enabled services
4. **Observability**: Enable Zipkin tracing and Prometheus metrics
5. **Production Deployment**: Add Ingress, autoscaling, and monitoring

## Version History

| Version | Date       | Changes                          | Author          |
|---------|------------|----------------------------------|-----------------|
| 1.0.0   | 2025-12-19 | Initial FastAPI Dapr playbook    | Claude Sonnet 4.5 |

---

**Compilation:** This playbook compiles to Claude Skills format using:
```bash
bash caps-library/scripts/caps-to-skills.sh fastapi-dapr-service --validate
```
