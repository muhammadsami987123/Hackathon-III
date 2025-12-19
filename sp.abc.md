# SP Specify Part 1: CAPS Format Specification

## Coding Agent Playbook Spec (CAPS) v1.0.0
### Claude CLI Skills Focus Edition

---

## TABLE OF CONTENTS

1. [Overview](#overview)
2. [Design Principles](#design-principles)
3. [CAPS File Structure](#caps-file-structure)
4. [Field Reference](#field-reference)
5. [Execution Model](#execution-model)
6. [Claude Skills Compilation](#claude-skills-compilation)
7. [Validation Rules](#validation-rules)
8. [Best Practices](#best-practices)
9. [Examples](#examples)

---

## OVERVIEW

**CAPS** (Coding Agent Playbook Spec) is a vendor-neutral, human-readable format for writing reusable instructions that Claude CLI can autonomously execute as Skills.

### The Problem CAPS Solves

Claude CLI Skills (introduced October 2025) provide a powerful way to extend Claude's capabilities, but writing them directly can be repetitive and error-prone. CAPS provides a single authoring format optimized for human clarity that compiles directly into Claude's `.claude/skills/` directory structure.

### The CAPS Solution

Write once in CAPS format → Compile to Claude Skills → Claude CLI executes them.

```
┌──────────────────────┐
│ CAPS Playbook (.md)  │
│ (Single Source)      │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Claude Skills        │
│ (SKILL.md format)    │
└──────────┬───────────┘
           │
           ▼
┌──────────────────────┐
│ Claude CLI           │
│ Execution            │
└──────────────────────┘
```

### Core Value Proposition

1. **Write Once:** Single CAPS file for infinite reuse
2. **Clear Format:** Markdown-based, human and machine readable
3. **Auto-compile:** Generate Claude Skills with single command
4. **Version Control:** Git-friendly, mergeable, reviewable
5. **Reusable:** Copy CAPS playbooks across projects
6. **Testable:** Validate before compilation

---

## DESIGN PRINCIPLES

### 1. Clarity Over Cleverness

CAPS prioritizes explicit, unambiguous instructions. Claude should never guess.

```markdown
✓ GOOD: "Run: helm install kafka bitnami/kafka --namespace kafka"
✗ BAD: "Set up Kafka" (too vague)
```

### 2. Structure Over Prose

CAPS uses hierarchical sections with clear purposes. Each section has a defined role.

```markdown
✓ GOOD: ## Step 3: Install PostgreSQL
✗ BAD: "Now you might want to install the database, which is important"
```

### 3. Tool Explicitness

Every tool must be declared upfront. No surprises.

```yaml
allowed_tools: [kubectl, helm, bash, docker]
# Agent knows exactly what it can use
```

### 4. Idempotency

Steps should be executable multiple times without side effects.

```bash
# ✓ Idempotent (safe to run 10 times)
kubectl create namespace kafka --dry-run=client -o yaml | kubectl apply -f -

# ✗ Not idempotent (fails on second run)
kubectl create namespace kafka
```

### 5. Validation by Default

Every playbook includes success criteria and validation steps.

```markdown
## Validation

Success indicators:
- [ ] kubectl get pods -n kafka returns 3 pods
- [ ] Kafka service is accessible: nc -zv kafka.kafka.svc 9092
```

### 6. Fail-Fast with Debugging

Include troubleshooting sections for common failures.

```markdown
## Troubleshooting

**Problem:** Pod stuck in Pending  
**Root Cause:** Insufficient memory  
**Check:** kubectl describe pod <n> | grep Events  
**Fix:** minikube start --memory=8192
```

---

## CAPS FILE STRUCTURE

### Anatomy of a CAPS Playbook

A CAPS file is a Markdown file with two distinct regions:

```markdown
---
YAML FRONTMATTER (Metadata)
---

# Markdown Content
(Instructions, steps, validation)
```

### File Naming Convention

```
playbooks/{domain}/{playbook_name}/playbook.md

Examples:
  playbooks/infra/kafka-k8s-setup/playbook.md
  playbooks/backend/fastapi-dapr-agent/playbook.md
  playbooks/tools/agents-md-gen/playbook.md
```

### Complete Structure Example

```markdown
---
title: Kafka Kubernetes Setup
description: Deploy Apache Kafka on Kubernetes using Helm
version: 1.0.0
category: infrastructure
tags: [kafka, kubernetes, helm, streaming]
difficulty: intermediate
estimated_time: 15
allowed_tools:
  - kubectl
  - helm
  - bash
prerequisites:
  - kubernetes_cluster_running
  - helm_installed
  - 4gb_ram_available
dependencies:
  - zookeeper-k8s-setup
  - namespace-setup
skip_conditions:
  - kafka_already_deployed
---

# Kafka Kubernetes Setup

A complete guide to deploying and configuring Apache Kafka on Kubernetes.

## Prerequisites

Before starting, verify:
- Kubernetes cluster is running: `kubectl cluster-info`
- Helm is installed: `helm version`
- Namespace exists: `kubectl get namespace kafka`

## Instructions

### Step 1: Add Bitnami Repository

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

Validation: `helm search repo bitnami/kafka`

### Step 2: Install Kafka

```bash
helm install kafka bitnami/kafka \
  --namespace kafka \
  --set replicaCount=1 \
  --set zookeeper.replicaCount=1 \
  --set resources.requests.memory=2Gi \
  --wait --timeout 5m
```

Validation: Monitor pod creation with `kubectl get pods -n kafka -w`

### Step 3: Create Topics

```bash
kubectl exec -it kafka-0 -n kafka -- \
  /opt/bitnami/kafka/bin/kafka-topics.sh \
    --create \
    --topic learning.explained \
    --bootstrap-server localhost:9092 \
    --partitions 3 \
    --replication-factor 1
```

Repeat for all topics: `learning.submitted`, `code.executed`, `exercise.failed`

## Validation

Success criteria (all must pass):

- [ ] **Pods Running:** `kubectl get pods -n kafka` shows 3+ Running pods
- [ ] **Kafka Accessible:** `kubectl get svc -n kafka` shows kafka-0 service
- [ ] **Topics Created:** Run `kafka-topics.sh --list` to confirm 4+ topics
- [ ] **Producer Test:** Successfully publish message to learning.explained topic
- [ ] **Consumer Test:** Successfully read published message

Quick validation script:
```bash
kubectl run kafka-test --image=bitnami/kafka:latest --rm -it -- \
  kafka-console-producer.sh --broker-list kafka-0.kafka:9092 \
  --topic learning.explained
```

## Troubleshooting

**Problem:** Pods stuck in Pending state  
**Symptoms:** `kubectl get pods -n kafka` shows Pending for >5 minutes  
**Root Cause:** Insufficient cluster resources  
**Solution:**
```bash
# Check resource requirements
kubectl describe pod kafka-0 -n kafka | grep -A 10 "Requests"

# Increase Minikube memory
minikube delete && minikube start --memory=8192 --cpus=4
```

**Problem:** Helm install fails with "version incompatible"  
**Symptoms:** `helm install` returns chart version error  
**Root Cause:** Kafka Helm chart version mismatch  
**Solution:**
```bash
# Find compatible version
helm search repo bitnami/kafka --versions

# Install specific version
helm install kafka bitnami/kafka --version 28.1.2 --namespace kafka
```

## Notes & References

- Bitnami Kafka Helm Chart: https://github.com/bitnami/charts/tree/main/bitnami/kafka
- Kafka on Kubernetes Best Practices: https://kafka.apache.org/documentation/#bestpractices

## Rollback Instructions

If deployment fails catastrophically:

```bash
# Remove Kafka release
helm uninstall kafka -n kafka

# Delete namespace (caution: deletes all resources)
kubectl delete namespace kafka
```

## Next Steps

Once Kafka is deployed and validated:

1. Deploy PostgreSQL
2. Configure topic retention policies
3. Set up monitoring and alerting
```

---

## FIELD REFERENCE

### Frontmatter Fields

All frontmatter fields are YAML. Fields marked **Required** must always be present.

#### **title** (Required)
- **Type:** String
- **Length:** 3-80 characters
- **Purpose:** Human-readable name of the playbook
- **Example:** `"Kafka Kubernetes Setup"`
- **Rules:**
  - Use title case
  - Be specific, not generic
  - Include technology names

#### **description** (Required)
- **Type:** String
- **Length:** 10-300 characters
- **Purpose:** One-sentence summary of what the playbook accomplishes
- **Example:** `"Deploy Apache Kafka on Kubernetes using Helm with topic configuration"`
- **Rules:**
  - Start with action verb (Deploy, Configure, Build, Setup)
  - Include primary technology
  - Describe the outcome, not the how

#### **version** (Required)
- **Type:** Semantic version string
- **Format:** `MAJOR.MINOR.PATCH`
- **Example:** `"1.0.0"`, `"2.3.1"`
- **Rules:**
  - Start at 1.0.0
  - Increment MAJOR for breaking changes
  - Increment MINOR for new steps
  - Increment PATCH for clarifications only

#### **category** (Recommended)
- **Type:** String (enum)
- **Valid Values:** `infrastructure`, `backend`, `frontend`, `tools`, `deployment`, `integration`, `testing`, `database`
- **Example:** `"infrastructure"`
- **Purpose:** Organize playbooks by domain
- **Compiler Use:** Filter playbooks by category

#### **tags** (Recommended)
- **Type:** Array of strings
- **Example:** `["kafka", "kubernetes", "helm", "streaming"]`
- **Purpose:** Enable search and cross-referencing
- **Rules:**
  - Use lowercase, hyphenated names
  - 3-8 tags per playbook
  - Include technology stack

#### **difficulty** (Recommended)
- **Type:** String (enum)
- **Valid Values:** `beginner`, `intermediate`, `advanced`, `expert`
- **Example:** `"intermediate"`
- **Purpose:** Set expectations for Claude and human readers

#### **estimated_time** (Recommended)
- **Type:** Integer (minutes)
- **Example:** `15`, `45`, `120`
- **Purpose:** Time to complete playbook (wall-clock time)
- **Rules:**
  - Realistic, not optimistic
  - Include waiting for pod startup, etc.

#### **allowed_tools** (Required)
- **Type:** Array of strings
- **Example:** `["kubectl", "helm", "bash", "docker", "docker-compose"]`
- **Purpose:** Declare which tools/commands the playbook uses
- **Rules:**
  - Only tools explicitly needed
  - Common tools: `bash`, `kubectl`, `helm`, `docker`, `git`, `python`, `npm`, `curl`
  - Used to validate Claude can execute playbook

#### **prerequisites** (Required)
- **Type:** Array of strings
- **Example:**
  ```yaml
  prerequisites:
    - kubernetes_cluster_running
    - helm_installed
    - minimum_4gb_ram
    - docker_daemon_running
  ```
- **Purpose:** Declare what must be true before starting
- **Rules:**
  - Use snake_case for readability
  - Be testable (Claude can verify)
  - Include versions if critical (e.g., "k8s_1.24_or_later")

#### **dependencies** (Optional)
- **Type:** Array of playbook names
- **Example:** `["namespace-setup", "helm-repo-setup"]`
- **Purpose:** Declare other playbooks that must run first
- **Compiler Use:** Build execution order
- **Rules:**
  - Use playbook names, not paths
  - Only direct dependencies, not transitive

#### **skip_conditions** (Optional)
- **Type:** Array of strings
- **Example:** `["kafka_already_deployed", "namespace_exists"]`
- **Purpose:** Conditions under which the playbook can be skipped
- **Rules:**
  - Checkable by bash/kubectl commands
  - Helps achieve idempotency

---

## EXECUTION MODEL

### Claude CLI Execution Flow

When Claude receives a CAPS-compiled Skill, it follows this flow:

```
1. PARSE SKILL.md
   ├─ Read YAML frontmatter
   ├─ Understand name and description
   └─ Parse ## Instructions section

2. ASSESS PREREQUISITES
   ├─ Read ## Prerequisites section
   ├─ Verify tools available
   ├─ Check if can skip (skip_conditions)
   └─ If missing: Ask user or explain blocker

3. EXECUTE STEPS
   ├─ Read ### Step N sections
   ├─ Execute bash commands
   ├─ Monitor output
   ├─ If error: Check troubleshooting
   └─ Adjust approach if needed

4. VALIDATE
   ├─ Run ## Validation checks
   ├─ If all pass: Mark complete
   └─ If fail: Debug with troubleshooting

5. REPORT
   ├─ Explain what was done
   ├─ Show results
   └─ Recommend next steps
```

### Step Format

Each step should follow this pattern:

```markdown
### Step N: [Action Name]

[Optional explanation paragraph]

```bash
command line here
```

[Optional post-command explanation]

Validation: [How Claude verifies this step worked]
```

### Command Blocks

All executable commands must be in triple-backtick markdown blocks with bash syntax:

```markdown
```bash
# This is executable
kubectl get pods
```
```

---

## CLAUDE SKILLS COMPILATION

### SKILL.md Format

Claude Skills use a specific Markdown format with YAML frontmatter. CAPS compiles directly to this format.

#### Generated SKILL.md Structure

```markdown
---
name: {slugified-title}
description: {description}
allowed-tools: [tool1, tool2, ...]
---

# {title}

{description paragraph}

## Prerequisites

[Formatted list of prerequisites]

## Instructions

[Complete ## Instructions section from CAPS]

## Validation

[Complete ## Validation section from CAPS]

## Troubleshooting

[Complete ## Troubleshooting section from CAPS]

## Next Steps

[Any ## Next Steps from CAPS]
```

#### Mapping Rules

| CAPS Field | Claude Skill | Location |
|-----------|--------------|----------|
| `title` | Becomes heading and `name` | First heading + frontmatter |
| `description` | Frontmatter + paragraph | frontmatter + intro |
| `allowed_tools` | `allowed-tools` | frontmatter |
| `instructions` | ## Instructions section | verbatim copy |
| `prerequisites` | ## Prerequisites section | formatted list |
| `troubleshooting` | ## Troubleshooting section | verbatim copy |
| `validation` | ## Validation section | verbatim copy |
| `version` | Comment in SKILL.md | metadata comment |

#### Naming Convention

The `name` field in Claude Skills must be:
- Lowercase
- Hyphen-separated (no underscores)
- 3-50 characters
- Unique within `.claude/skills/` directory

```
CAPS Title: "Kafka Kubernetes Setup"
  ↓
Slugified: "kafka-kubernetes-setup"
  ↓
SKILL.md location: .claude/skills/kafka-kubernetes-setup/SKILL.md
```

#### Example Generated SKILL.md

```markdown
---
name: kafka-kubernetes-setup
description: Deploy Apache Kafka on Kubernetes using Helm with topic configuration
allowed-tools: [kubectl, helm, bash]
---

# Kafka Kubernetes Setup

Deploy Apache Kafka on Kubernetes using Helm with topic configuration.

## Prerequisites

Verify before starting:
- Kubernetes cluster is running (`kubectl cluster-info`)
- Helm is installed (`helm version`)
- Namespace exists (`kubectl get namespace kafka`)
- At least 4GB RAM available for pods
- Docker daemon is running

## Instructions

### Step 1: Add Bitnami Repository

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

Validation: `helm search repo bitnami/kafka`

[... rest of instructions ...]

## Validation

Success criteria (all must pass):

- [ ] **Pods Running:** `kubectl get pods -n kafka` shows 3+ Running pods
- [ ] **Kafka Accessible:** `kubectl get svc -n kafka` shows kafka-0 service
- [ ] **Topics Created:** Confirm 4+ topics exist
- [ ] **Producer Test:** Successfully publish test message
- [ ] **Consumer Test:** Successfully consume test message

## Troubleshooting

**Problem:** Pods stuck in Pending state
**Symptoms:** `kubectl get pods -n kafka` shows Pending for >5 minutes
**Root Cause:** Insufficient cluster resources
**Solution:**
```bash
minikube delete
minikube start --memory=8192 --cpus=4
```

[... more troubleshooting ...]

## Next Steps

1. Deploy PostgreSQL
2. Configure topic retention policies
3. Set up monitoring and alerting
```

---

## VALIDATION RULES

Every CAPS file must pass these validation checks before compilation:

### 1. Frontmatter Validation

```bash
# Check: All required fields present
REQUIRED_FIELDS=(title description version allowed_tools prerequisites)

# Check: YAML syntax valid
yamllint playbooks/*/playbook.md

# Check: No fields misspelled
# Correct: allowed_tools (CAPS)
# Correct: allowed-tools (Claude Skill - auto-converted)

# Check: Arrays are proper YAML
# ✓ allowed_tools: [item1, item2]
# ✗ allowed_tools: item1, item2 (invalid)
```

### 2. Markdown Structure Validation

```bash
# Check: Required sections exist
# Must have: ## Prerequisites, ## Instructions, ## Validation

# Check: Code blocks are properly formatted
# ✓ ```bash
# ✗ ```shell or unclosed blocks

# Check: Step numbering is consecutive
# ✓ ### Step 1, ### Step 2, ### Step 3
# ✗ ### Step 1, ### Step 3 (missing 2)
```

### 3. Content Validation

```bash
# Check: All tools are valid Claude-compatible tools
VALID_TOOLS=(bash kubectl helm docker git python nodejs npm curl)

# Check: Prerequisites are testable
# ✓ "kubernetes_cluster_running" → testable via kubectl
# ✗ "kubernetes_installed" → too vague

# Check: Validation criteria are measurable
# ✓ "kubectl get pods returns 3 pods in Running state"
# ✗ "Kubernetes works"

# Check: No hardcoded secrets
grep -E "password|apikey|token|secret" playbooks/*/playbook.md
```

### 4. Semantic Validation

```bash
# Check: Commands are idempotent where possible
# kubectl create → kubectl apply preferred

# Check: Troubleshooting covers common errors
# Minimum 2 problems documented

# Check: Instructions are sequential
# Steps follow logical order
```

### Validation Script

```bash
#!/bin/bash
# validate-caps.sh

PLAYBOOK_FILE=$1

echo "Validating $PLAYBOOK_FILE..."

# Extract YAML frontmatter
YAML=$(sed -n '/^---$/,/^---$/p' "$PLAYBOOK_FILE")

# Check required fields
for field in title description version allowed_tools prerequisites; do
  if ! echo "$YAML" | grep -q "^$field:"; then
    echo "❌ ERROR: Missing required field: $field"
    exit 1
  fi
done

# Check markdown sections
for section in "## Prerequisites" "## Instructions" "## Validation"; do
  if ! grep -q "$section" "$PLAYBOOK_FILE"; then
    echo "❌ ERROR: Missing required section: $section"
    exit 1
  fi
done

# Check code block syntax
if grep -q '```' "$PLAYBOOK_FILE"; then
  OPENS=$(grep -c '^```' "$PLAYBOOK_FILE" || true)
  if [ $((OPENS % 2)) -ne 0 ]; then
    echo "❌ ERROR: Unmatched code block markers"
    exit 1
  fi
fi

echo "✅ Validation passed for $PLAYBOOK_FILE"
```

---

## BEST PRACTICES

### 1. Writing Clear Instructions

**DO:**
```markdown
### Step 2: Create Kafka Topics

First, verify the Kafka pod is running:

```bash
kubectl get pods -n kafka | grep kafka-0
```

Once confirmed, create the required topics:

```bash
kubectl exec kafka-0 -n kafka -- \
  kafka-topics.sh --create \
  --topic learning.explained \
  --bootstrap-server localhost:9092
```

Verify creation:
```bash
kubectl exec kafka-0 -n kafka -- \
  kafka-topics.sh --list --bootstrap-server localhost:9092
```
```

**DON'T:**
```markdown
### Step 2: Topic Creation

Make the topics. Run this:
```bash
kafka-topics.sh --create --topic learning.explained
```
You might need to check if it worked.
```

### 2. Tool Declarations

**DO:**
```yaml
allowed_tools:
  - kubectl
  - helm
  - bash
```

**DON'T:**
```yaml
allowed_tools:
  - k8s
  - "kubectl/helm"
  - linux commands
```

### 3. Prerequisites That Are Testable

**DO:**
```yaml
prerequisites:
  - kubernetes_cluster_running        # testable: kubectl cluster-info
  - helm_3_12_or_later               # testable: helm version
  - minimum_4gb_memory_available      # testable: free -h
  - docker_daemon_running             # testable: docker info
```

**DON'T:**
```yaml
prerequisites:
  - kubernetes
  - helm
  - enough memory
  - docker setup
```

### 4. Idempotent Commands

**DO:**
```bash
# Safe to run multiple times
kubectl apply -f manifest.yaml

# Or with --dry-run
kubectl create namespace kafka --dry-run=client -o yaml | kubectl apply -f -
```

**DON'T:**
```bash
# Fails on second run
kubectl create namespace kafka
```

### 5. Comprehensive Troubleshooting

**DO:**
```markdown
## Troubleshooting

**Problem:** Kafka pod stuck in Pending state
**Symptoms:** kubectl get pods shows Pending for 5+ minutes
**Root Cause:** Insufficient cluster memory
**Check:** kubectl describe pod kafka-0 | grep Events
**Fix:**
```bash
minikube delete
minikube start --memory=8192 --cpus=4
```

**Verify:**
```bash
kubectl get pods  # Should show Running
```
```

**DON'T:**
```markdown
## Troubleshooting

If it doesn't work, try restarting or checking logs.
```

### 6. Step-by-Step Clarity

**DO:**
```markdown
### Step 1: Install Helm Repository

Begin by adding the Bitnami Helm repository, which contains pre-built 
Kubernetes charts for popular applications like Kafka and PostgreSQL:

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
```

Then update your local Helm cache to fetch the latest charts:

```bash
helm repo update
```

Verify the repository was added successfully:

```bash
helm repo list | grep bitnami
```

You should see output like: `bitnami    https://charts.bitnami.com/bitnami`
```

**DON'T:**
```markdown
### Step 1: Add repo

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```
```

---

## EXAMPLES

### Example 1: Infrastructure Playbook (PostgreSQL)

```markdown
---
title: PostgreSQL Kubernetes Setup
description: Deploy PostgreSQL on Kubernetes with persistent storage
version: 1.0.0
category: infrastructure
tags: [postgresql, kubernetes, helm, database]
difficulty: intermediate
estimated_time: 20
allowed_tools:
  - kubectl
  - helm
  - bash
prerequisites:
  - kubernetes_cluster_running
  - helm_3_12_or_later
  - minimum_4gb_memory
dependencies:
  - namespace-setup
skip_conditions:
  - postgresql_already_deployed
---

# PostgreSQL Kubernetes Setup

Deploy a production-ready PostgreSQL instance on Kubernetes with persistent storage, automated backups, and monitoring integration.

## Prerequisites

Verify these before starting:

```bash
# Kubernetes running
kubectl cluster-info

# Helm installed
helm version --short

# Sufficient resources
free -h | grep Mem
```

## Instructions

### Step 1: Add Bitnami Repository

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

Validation: `helm search repo bitnami/postgresql` returns results

### Step 2: Create PostgreSQL Secret

Create a secret for the database password:

```bash
kubectl create secret generic postgresql-password \
  --from-literal=password=SecurePassword123! \
  -n postgres \
  --dry-run=client -o yaml | kubectl apply -f -
```

Validation: `kubectl get secret -n postgres`

### Step 3: Install PostgreSQL

```bash
helm install postgresql bitnami/postgresql \
  --namespace postgres \
  --set auth.existingSecret=postgresql-password \
  --set auth.username=learnflow \
  --set auth.database=learnflow_db \
  --set primary.persistence.size=10Gi \
  --wait --timeout 5m
```

Validation: `kubectl get pods -n postgres -w`

### Step 4: Verify Installation

```bash
# Check pods
kubectl get pods -n postgres

# Port-forward for testing
kubectl port-forward svc/postgresql 5432:5432 -n postgres &
```

## Validation

All checks must pass:

- [ ] **Primary Pod Running:** `kubectl get pods -n postgres` shows Running
- [ ] **Service Exists:** `kubectl get svc postgresql -n postgres`
- [ ] **Database Created:** Listed in database list
- [ ] **Connection Test:** Can connect with psql client

## Troubleshooting

**Problem:** Pod stuck in Pending
**Symptoms:** kubectl get pods shows Pending for 5+ minutes
**Root Cause:** Insufficient memory or storage class missing
**Check:**
```bash
kubectl describe pod postgresql-0 -n postgres
kubectl get storageclass
```
**Fix:**
```bash
minikube delete
minikube start --memory=8192 --cpus=4
```

**Problem:** Authentication failed
**Symptoms:** Connection returns "password authentication failed"
**Root Cause:** Secret not properly mounted
**Check:**
```bash
kubectl get secret postgresql-password -n postgres -o yaml
```
**Fix:**
```bash
kubectl delete secret postgresql-password -n postgres
kubectl create secret generic postgresql-password \
  --from-literal=password=$NEW_PASSWORD -n postgres
kubectl rollout restart statefulset/postgresql -n postgres
```

## Rollback

```bash
helm uninstall postgresql -n postgres
kubectl delete pvc -n postgres
kubectl delete namespace postgres
```

## Next Steps

1. Create database tables
2. Set up automated backups
3. Configure monitoring
4. Test failover scenarios
```

### Example 2: Backend Service Playbook (FastAPI)

```markdown
---
title: FastAPI Microservice with Kafka Integration
description: Create a FastAPI service with Kafka pub/sub messaging
version: 1.0.0
category: backend
tags: [fastapi, python, microservices, kafka]
difficulty: advanced
estimated_time: 30
allowed_tools:
  - kubectl
  - bash
  - docker
  - python
prerequisites:
  - kubernetes_cluster_running
  - docker_daemon_running
  - python_3_10_or_later
  - kafka_deployed_and_accessible
dependencies:
  - kafka-k8s-setup
skip_conditions:
  - service_already_deployed
---

# FastAPI Microservice with Kafka Integration

Create a FastAPI-based Python service that integrates with Kafka for event-driven communication.

## Prerequisites

Verify before starting:

```bash
# Python version
python3 --version  # Should be 3.10+

# Docker
docker ps

# Kafka accessible
kubectl get svc -n kafka | grep kafka
```

## Instructions

### Step 1: Create Project Structure

```bash
mkdir -p fastapi-service
cd fastapi-service

mkdir -p {src,config,k8s,tests}

# Create virtual environment
python3 -m venv venv
source venv/bin/activate

# Create requirements.txt
cat > requirements.txt << 'EOF'
fastapi==0.104.1
uvicorn==0.24.0
pydantic==2.5.0
EOF

pip install -r requirements.txt
```

### Step 2: Create FastAPI Service

Create `src/app.py`:

```python
from fastapi import FastAPI
from pydantic import BaseModel

class HealthResponse(BaseModel):
    status: str
    service: str

app = FastAPI(title="FastAPI Service", version="1.0.0")

@app.get("/health", response_model=HealthResponse)
async def health():
    return {"status": "healthy", "service": "fastapi"}

@app.post("/code/execute")
async def execute_code(code: str):
    return {"status": "submitted", "code": code}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
```

Test locally:

```bash
python src/app.py &
curl http://localhost:8000/health
kill %1
```

### Step 3: Create Dockerfile

Create `Dockerfile`:

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY src/ .
CMD ["uvicorn", "app:app", "--host", "0.0.0.0", "--port", "8000"]
```

Build image:

```bash
docker build -t fastapi-service:latest .
```

### Step 4: Create Kubernetes Manifests

Create `k8s/deployment.yaml`:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: fastapi-service
  namespace: learnflow
spec:
  replicas: 2
  selector:
    matchLabels:
      app: fastapi-service
  template:
    metadata:
      labels:
        app: fastapi-service
    spec:
      containers:
      - name: fastapi-service
        image: fastapi-service:latest
        imagePullPolicy: Never
        ports:
        - containerPort: 8000
        resources:
          requests:
            cpu: 100m
            memory: 256Mi
          limits:
            cpu: 500m
            memory: 512Mi

---
apiVersion: v1
kind: Service
metadata:
  name: fastapi-service
  namespace: learnflow
spec:
  selector:
    app: fastapi-service
  ports:
  - port: 8000
    targetPort: 8000
  type: ClusterIP
```

Deploy:

```bash
kubectl create namespace learnflow --dry-run=client -o yaml | kubectl apply -f -
kubectl apply -f k8s/deployment.yaml
kubectl rollout status deployment/fastapi-service -n learnflow
```

### Step 5: Test the Service

```bash
# Port-forward
kubectl port-forward svc/fastapi-service 8000:8000 -n learnflow &

# Test endpoint
curl http://localhost:8000/health

# Test POST
curl -X POST http://localhost:8000/code/execute \
  -H "Content-Type: application/json" \
  -d '{"code": "print(1+1)"}'
```

## Validation

All checks must pass:

- [ ] **Pods Running:** `kubectl get pods -n learnflow` shows Running
- [ ] **Service Accessible:** `kubectl get svc fastapi-service -n learnflow`
- [ ] **Health Check:** curl returns status: healthy
- [ ] **Deployment Ready:** Rollout status shows success
- [ ] **Log Check:** `kubectl logs -l app=fastapi-service -n learnflow`

## Troubleshooting

**Problem:** ImagePullBackOff error
**Symptoms:** Pod shows ImagePullBackOff status
**Root Cause:** Docker image not in registry or pull policy wrong
**Check:**
```bash
kubectl describe pod <pod-name> -n learnflow | grep Events
```
**Fix:**
```bash
# Rebuild image and use Never pull policy
docker build -t fastapi-service:latest .
# Already set in deployment.yaml: imagePullPolicy: Never
kubectl rollout restart deployment/fastapi-service -n learnflow
```

**Problem:** Connection refused on port 8000
**Symptoms:** curl: (7) Failed to connect
**Root Cause:** Service not ready or port not accessible
**Check:**
```bash
kubectl get svc fastapi-service -n learnflow
kubectl get pods -n learnflow
```
**Fix:**
```bash
# Wait for pods to be ready
kubectl wait --for=condition=Ready pod \
  -l app=fastapi-service -n learnflow --timeout=60s

# Then port-forward again
kubectl port-forward svc/fastapi-service 8000:8000 -n learnflow
```

## Next Steps

1. Add Kafka consumer functionality
2. Implement authentication
3. Add database integration
4. Set up logging and monitoring
```

### Example 3: Tools Playbook (AGENTS.md Generation)

```markdown
---
title: Generate AGENTS.md Documentation
description: Create AGENTS.md files to help Claude understand repository structure
version: 1.0.0
category: tools
tags: [documentation, automation, agents]
difficulty: beginner
estimated_time: 10
allowed_tools:
  - bash
prerequisites:
  - bash_4_or_later
  - git_repository_initialized
skip_conditions:
  - agents_md_already_exists
---

# Generate AGENTS.md Documentation

Create an AGENTS.md file that describes your repository structure for Claude.

## Prerequisites

```bash
# Bash version
bash --version | head -1

# Git repository
git status

# Working directory has files
ls *.md *.py *.yml 2>/dev/null
```

## Instructions

### Step 1: Create AGENTS.md in Repository Root

```bash
cat > AGENTS.md << 'EOF'
# AGENTS.md: Repository Guide for AI Agents

This file describes the structure and conventions to help AI agents understand this codebase.

## Repository Structure

\`\`\`
.
├── README.md                 # Project overview
├── docs/                     # Documentation
├── src/                      # Source code
│   ├── api/                  # API services
│   └── utils/                # Helper functions
├── k8s/                      # Kubernetes manifests
├── Dockerfile                # Container definition
└── .github/workflows/        # CI/CD pipelines
\`\`\`

## Key Conventions

### Naming Conventions

- **Python files:** snake_case (e.g., user_service.py)
- **Python classes:** PascalCase (e.g., UserService)
- **Directories:** lowercase, hyphenated (e.g., api-services/)
- **Git branches:** feature/description, bugfix/description

### Code Style

- Python: Follow PEP 8
- Markdown: Max 80 chars per line
- YAML: 2-space indentation
- Bash: Quote variables, use set -e

### Testing

- Unit tests in tests/ directory
- Run tests before committing
- Test coverage minimum 80%

## How AI Agents Should Work

1. **Read this file first** to understand structure
2. **Check existing patterns** before writing new code
3. **Run tests after changes**
4. **Follow naming conventions** throughout
5. **Update AGENTS.md** if structure changes

## Common Tasks

### Add API Endpoint

1. Create handler in src/api/
2. Add route definitions
3. Create tests in tests/
4. Update README

### Deploy to Kubernetes

1. Update Dockerfile
2. Modify k8s/deployment.yaml
3. Run kubectl apply
4. Verify with kubectl rollout status

## Technology Stack

- **Language:** Python 3.10+
- **Framework:** FastAPI
- **Container:** Docker, Kubernetes
- **Messaging:** Kafka

## Important Files

- \`requirements.txt\` - Dependencies
- \`docker-compose.yml\` - Local dev
- \`k8s/deployment.yaml\` - Production

---

Last updated: 2025-12-18
Maintainer: Your Name/Team
EOF
```

### Step 2: Verify File Created

```bash
# Check file exists and has content
test -f AGENTS.md && echo "✓ AGENTS.md created"
wc -l AGENTS.md
```

### Step 3: Add to Git

```bash
git add AGENTS.md
git commit -m "Add: AGENTS.md for AI agent guidance"
git log --oneline | head -1
```

## Validation

All checks must pass:

- [ ] **File Exists:** `ls AGENTS.md` shows no error
- [ ] **Has Content:** File is > 200 bytes
- [ ] **Committed:** File in git history
- [ ] **Readable:** `cat AGENTS.md` displays correctly

## Troubleshooting

**Problem:** Permission denied
**Symptoms:** "cannot create AGENTS.md: Permission denied"
**Root Cause:** Directory is read-only
**Fix:**
```bash
# Check directory permissions
ls -ld .

# Or create in temp directory
cd /tmp && mkdir test-repo && cd test-repo
```

**Problem:** Git commit fails
**Symptoms:** "fatal: not a git repository"
**Root Cause:** Not in git directory
**Fix:**
```bash
# Initialize git
git init

# Or navigate to repo
cd /path/to/your/repo
```

## Next Steps

1. Share AGENTS.md with your team
2. Update it as structure changes
3. Reference when onboarding developers
4. Use to train Claude on your codebase
```

---

## CAPS FORMAT SUMMARY

| Aspect | Details |
|--------|---------|
| **File Extension** | .md (Markdown) |
| **Location** | playbooks/{domain}/{name}/playbook.md |
| **Frontmatter** | YAML between `---` markers |
| **Content** | Markdown with hierarchical sections |
| **Audience** | Both Claude and human readers |
| **Compilation Target** | Claude CLI Skills (.claude/skills/) |
| **Version** | Semantic versioning (MAJOR.MINOR.PATCH) |

---

## NEXT STEPS

With CAPS specification complete, proceed to:

1. **Create CAPS-to-Skills Compiler** (script to generate SKILL.md files)
2. **Write First Playbooks** (agents-md-gen, kubernetes-setup)
3. **Test with Claude CLI** (Verify generated Skills work with claude commands)
4. **Iterate** (Refine playbooks based on Claude's execution results)

---

**CAPS v1.0.0 Specification Complete** ✓

**Claude CLI Edition** - Optimized for Claude's skill system

Last Updated: December 18, 2025