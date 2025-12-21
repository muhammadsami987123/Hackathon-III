# Repository Setup

**Initialize skills-library and learnflow-app repositories for Hackathon III**

**Prerequisites**: [Environment setup complete](./README.md) and [verified](./verification.md)

---

## Overview

This guide walks you through creating two required repositories with correct directory structure:

1. **skills-library**: CAPS playbooks and compiled Skills/Recipes
2. **learnflow-app**: LearnFlow application (AI-powered Python tutoring platform)

Both repositories follow the project constitution structure requirements.

---

## Part 1: Create skills-library Repository

### Step 1: Create Directory and Initialize Git

```bash
# Create directory
mkdir -p ~/projects/skills-library
cd ~/projects/skills-library

# Initialize git
git init
```

**Expected**: `Initialized empty Git repository in ~/projects/skills-library/.git/`

---

### Step 2: Create .claude/skills Directory Structure

```bash
# Create Claude Skills directory
mkdir -p .claude/skills

# Create commands directory (for slash commands)
mkdir -p .claude/commands
```

**Purpose**:
- `.claude/skills/`: Compiled Claude Skills from CAPS playbooks
- `.claude/commands/`: Slash command definitions (e.g., /sp.tasks, /sp.plan)

---

### Step 3: Create .goose/recipes Directory Structure

```bash
# Create Goose Recipes directory
mkdir -p .goose/recipes
```

**Purpose**: Compiled Goose Recipes from CAPS playbooks (for Goose agent compatibility)

---

### Step 4: Create Initial README

```bash
cat > README.md << 'EOF'
# Skills Library

Reusable AI skills for Claude Code and Goose - Hackathon III

## Skills Included

Skills are compiled from CAPS playbooks and work with both Claude Code and Goose agents.

## Directory Structure

```
.claude/
├── commands/      # Slash command definitions
└── skills/        # Compiled Claude Skills

.goose/
└── recipes/       # Compiled Goose Recipes
```

## Usage

### With Claude Code
```bash
claude --skill <skill-name>
# or use slash commands: /sp.tasks, /sp.plan, etc.
```

### With Goose
```bash
goose --recipe <recipe-name>
```

## Development

Skills are generated from CAPS playbooks located in `caps-library/playbooks/`.

## Constitution Compliance

This repository follows SP Constitution (Spec-Kit Plus) principles:
- **Principle I**: CAPS-First Development
- **Principle II**: Bi-Directional Compilation (Claude Skills + Goose Recipes)
- **Principle VII**: Test-Driven Refinement for playbooks

See `.specify/memory/constitution.md` for full governance.
EOF
```

---

### Step 5: Create Initial Commit

```bash
# Stage all files
git add .

# Create initial commit
git commit -m "Initial: Create skills-library

- Initialize repository structure
- Add .claude/skills and .goose/recipes directories
- Add README with usage instructions

🤖 Generated during Hackathon III environment setup"
```

**Expected**: Commit created successfully

---

### Step 6: Verify skills-library Structure

```bash
# Check directory structure
find . -type d -name ".git" -prune -o -type d -print

# Verify git initialization
git log --oneline
```

**Expected Structure**:
```
.
├── .claude
│   ├── commands
│   └── skills
├── .goose
│   └── recipes
└── README.md
```

**Expected Git Log**: Shows "Initial: Create skills-library" commit

---

## Part 2: Create learnflow-app Repository

### Step 1: Create Directory and Initialize Git

```bash
# Create directory
mkdir -p ~/projects/learnflow-app
cd ~/projects/learnflow-app

# Initialize git
git init
```

---

### Step 2: Create Application Directory Structure

```bash
# Create source directories
mkdir -p src/frontend
mkdir -p src/services
mkdir -p src/k8s

# Create docs directory
mkdir -p docs
```

**Purpose**:
- `src/frontend/`: Next.js + Monaco Editor UI
- `src/services/`: FastAPI + Dapr microservices
- `src/k8s/`: Kubernetes manifests
- `docs/`: Docusaurus documentation

---

### Step 3: Create Initial README

```bash
cat > README.md << 'EOF'
# LearnFlow Application

AI-powered Python tutoring platform - Hackathon III

## Architecture

- **Frontend**: Next.js + Monaco Editor (in-browser code editor)
- **Backend**: FastAPI + Dapr + OpenAI Agents
- **Messaging**: Kafka on Kubernetes
- **Database**: PostgreSQL
- **Orchestration**: Kubernetes (Minikube for local dev)

## Project Structure

```
src/
├── frontend/       # Next.js application
├── services/       # FastAPI microservices
└── k8s/            # Kubernetes manifests

docs/               # Docusaurus documentation
```

## Building

This application is built using CAPS playbooks from `../skills-library`:
- `kafka-k8s-setup`: Deploy Kafka
- `postgresql-k8s-setup`: Deploy PostgreSQL
- `fastapi-dapr-service`: Create Dapr-enabled FastAPI services
- `nextjs-k8s-deploy`: Deploy Next.js frontend

## Development Workflow

1. **Local Kubernetes**: Minikube (4 CPU, 8GB RAM)
2. **Deploy Infrastructure**: Kafka, PostgreSQL via CAPS playbooks
3. **Deploy Services**: FastAPI agents via Dapr sidecars
4. **Deploy Frontend**: Next.js with Monaco Editor
5. **Access**: Port-forward or Minikube service URLs

## Constitution Compliance

This application follows SP Constitution principles:
- **Principle III**: Phase-Gate Development
- **Principle IV**: Kubernetes-Native Architecture
- **Principle V**: MCP Integration for AI Observability
- **Principle VI**: Documentation as Automated Deliverable
- **Principle VIII**: Feature Parity (Claude & Goose builds)

See `.specify/memory/constitution.md` for governance.
EOF
```

---

### Step 4: Create Initial Commit

```bash
# Stage all files
git add .

# Create initial commit
git commit -m "Initial: Create learnflow-app

- Initialize repository structure
- Add src/ directories (frontend, services, k8s)
- Add docs/ directory
- Add README with architecture overview

🤖 Generated during Hackathon III environment setup"
```

---

### Step 5: Verify learnflow-app Structure

```bash
# Check directory structure
find . -type d -name ".git" -prune -o -type d -print

# Verify git initialization
git log --oneline
```

**Expected Structure**:
```
.
├── docs
├── src
│   ├── frontend
│   ├── k8s
│   └── services
└── README.md
```

**Expected Git Log**: Shows "Initial: Create learnflow-app" commit

---

## Verification Checklist

After completing both repositories, verify:

### skills-library

- [ ] Directory exists at `~/projects/skills-library`
- [ ] Git initialized (`.git/` directory exists)
- [ ] `.claude/skills/` directory exists
- [ ] `.claude/commands/` directory exists
- [ ] `.goose/recipes/` directory exists
- [ ] `README.md` exists
- [ ] Initial commit exists (`git log` shows commit)

### learnflow-app

- [ ] Directory exists at `~/projects/learnflow-app`
- [ ] Git initialized (`.git/` directory exists)
- [ ] `src/frontend/` directory exists
- [ ] `src/services/` directory exists
- [ ] `src/k8s/` directory exists
- [ ] `docs/` directory exists
- [ ] `README.md` exists
- [ ] Initial commit exists (`git log` shows commit)

---

## Verification Commands

Run these commands to verify structure:

```bash
# Verify skills-library
cd ~/projects/skills-library
ls -la
git log --oneline
find . -type d -name ".git" -prune -o -type d -print

# Verify learnflow-app
cd ~/projects/learnflow-app
ls -la
git log --oneline
find . -type d -name ".git" -prune -o -type d -print
```

**Expected**: All directories present, git logs show initial commits

---

## Next Steps

✅ **Repositories Created!**

1. **Explore CAPS playbooks**: Review existing playbooks in hackathon repository
2. **Build skills**: Compile CAPS playbooks to Skills/Recipes
3. **Develop LearnFlow**: Use CAPS playbooks to deploy infrastructure and services
4. **Follow Constitution**: Adhere to phase-gate development and CAPS-first principles

---

## Troubleshooting

**Git not initialized**:
```bash
cd <repository-directory>
git init
```

**Missing directories**:
```bash
# Recreate structure
mkdir -p .claude/skills .claude/commands .goose/recipes  # for skills-library
mkdir -p src/{frontend,services,k8s} docs  # for learnflow-app
```

**Commit failed**:
- Ensure files are staged: `git add .`
- Check git configuration: `git config --list`
- Set git user if needed:
  ```bash
  git config user.name "Your Name"
  git config user.email "your.email@example.com"
  ```

---

**Repository Setup Complete!** 🎉

*You now have the foundational repositories for Hackathon III CAPS-first development.*

*Part of Hackathon III: SP Constitution (Spec-Kit Plus)*
