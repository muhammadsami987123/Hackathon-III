---
title: Deploy Docker Container
description: Deploy a containerized application using Docker
version: 1.0.0
allowed_tools:
  - docker
  - bash
prerequisites:
  - docker_installed
  - docker_daemon_running
---

# Deploy Docker Container

Deploy a containerized application using Docker with proper configuration and health checks.

## Prerequisites

- Docker installed (version 20.0+)
- Docker daemon running
- Application image available locally or in registry
- Port 8080 available on host

## Instructions

### Step 1: Pull Image

```bash
# Pull the application image
docker pull myapp:latest
```

### Step 2: Run Container

```bash
# Run container with port mapping and restart policy
docker run -d \
  --name myapp \
  -p 8080:8080 \
  --restart unless-stopped \
  myapp:latest
```

### Step 3: Verify Health

```bash
# Check container status
docker ps | grep myapp

# Test application endpoint
curl http://localhost:8080/health
```

## Validation

Success criteria:
- [ ] Container running (docker ps shows "Up" status)
- [ ] Port 8080 accessible
- [ ] Health endpoint returns 200 OK
- [ ] Application logs show no errors

## Troubleshooting

**Problem**: Port 8080 already in use
**Solution**:
1. Find conflicting process: `sudo lsof -i :8080`
2. Stop conflicting service or use different port: `-p 8081:8080`

**Problem**: Container exits immediately
**Solution**: Check logs with `docker logs myapp` for application errors
