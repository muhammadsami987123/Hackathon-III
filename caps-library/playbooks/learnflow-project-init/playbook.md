---
title: LearnFlow Project Initialization
description: Bootstrap LearnFlow project structure with dual-agent support (Claude and Goose) following constitution requirements
version: 1.0.0
category: integration
tags:
  - learnflow
  - project-setup
  - dual-agent
  - constitution
difficulty: intermediate
estimated_time: 15
allowed_tools:
  - bash
  - git
prerequisites:
  - git_installed
  - bash_4_or_later
  - write_permission_parent_directory
---

# LearnFlow Project Initialization

This playbook creates the complete LearnFlow project structure following SP Constitution Principle VIII (Explicit Feature Parity Between Agent Builds). It sets up both `learnflow-claude/` and `learnflow-goose/` directories with identical structure, ensuring dual-agent development readiness.

By the end of this playbook, you will have a complete LearnFlow project skeleton with:
- Dual-agent directory structure (Claude + Goose)
- Kubernetes manifests directories
- Frontend and backend service scaffolding
- AGENTS.md files for AI observability
- Constitution-compliant git configuration

## Prerequisites

Before starting this playbook, ensure the following prerequisites are met:

**Required Software:**
```bash
# Check Git installed
git --version
# Expected: git version 2.30.0 or later

# Check Bash version
bash --version | head -1
# Expected: GNU bash, version 4.0 or later

# Check write permissions
touch test-write && rm test-write && echo "✓ Write permission OK"
# Expected: ✓ Write permission OK
```

**Required Permissions:**
- Write permission in parent directory where LearnFlow will be created

**Environment Setup:**
```bash
# Decide where to create LearnFlow
cd /path/to/your/workspace
# Example: cd ~/projects/hackathon
```

## Instructions

### Step 1: Create Root Project Directory

**Objective:** Create the main LearnFlow project directory

**Commands:**
```bash
# Create project root
mkdir -p learnflow
cd learnflow

# Initialize git repository
git init
git branch -M main

# Verify directory created
pwd
# Should show: /path/to/workspace/learnflow
```

**Expected Output:**
```
Initialized empty Git repository in /path/to/workspace/learnflow/.git/
```

**Success Criteria:**
- [ ] learnflow/ directory exists
- [ ] Git repository initialized
- [ ] On main branch

---

### Step 2: Create Claude Agent Directory Structure

**Objective:** Set up learnflow-claude/ with full project structure per constitution

**Commands:**
```bash
# Create learnflow-claude directory structure
mkdir -p learnflow-claude/{.claude/{commands,skills},src/{frontend,services,k8s},docs}

# Create service subdirectories
mkdir -p learnflow-claude/src/services/{agent-orchestrator,curriculum-manager,mastery-engine,code-runner}

# Create K8s subdirectories
mkdir -p learnflow-claude/src/k8s/{deployments,services,configmaps,secrets}

# Verify structure
tree learnflow-claude -L 3 -d || find learnflow-claude -type d | head -20
```

**Expected Output:**
```
learnflow-claude/
├── .claude/
│   ├── commands/
│   └── skills/
├── docs/
└── src/
    ├── frontend/
    ├── k8s/
    │   ├── configmaps/
    │   ├── deployments/
    │   ├── secrets/
    │   └── services/
    └── services/
        ├── agent-orchestrator/
        ├── code-runner/
        ├── curriculum-manager/
        └── mastery-engine/
```

**Success Criteria:**
- [ ] learnflow-claude/ created with all subdirectories
- [ ] .claude/ directory for Skills present
- [ ] 4 service directories created
- [ ] K8s manifests structure ready

---

### Step 3: Create Goose Agent Directory Structure

**Objective:** Set up learnflow-goose/ with identical structure (Principle VIII: Feature Parity)

**Commands:**
```bash
# Create learnflow-goose directory structure (mirrors Claude)
mkdir -p learnflow-goose/{.goose/recipes,src/{frontend,services,k8s},docs}

# Create service subdirectories (identical to Claude)
mkdir -p learnflow-goose/src/services/{agent-orchestrator,curriculum-manager,mastery-engine,code-runner}

# Create K8s subdirectories (identical to Claude)
mkdir -p learnflow-goose/src/k8s/{deployments,services,configmaps,secrets}

# Verify structure matches Claude
tree learnflow-goose -L 3 -d || find learnflow-goose -type d | head -20
```

**Expected Output:**
```
learnflow-goose/
├── .goose/
│   └── recipes/
├── docs/
└── src/
    ├── frontend/
    ├── k8s/
    │   ├── configmaps/
    │   ├── deployments/
    │   ├── secrets/
    │   └── services/
    └── services/
        ├── agent-orchestrator/
        ├── code-runner/
        ├── curriculum-manager/
        └── mastery-engine/
```

**Success Criteria:**
- [ ] learnflow-goose/ created with all subdirectories
- [ ] .goose/ directory for Recipes present
- [ ] Service directories match Claude structure exactly
- [ ] K8s structure identical to Claude

---

### Step 4: Create AGENTS.md Files

**Objective:** Create AI-readable structure documentation per Constitution Principle V

**Commands:**
```bash
# Create AGENTS.md for Claude version
cat > learnflow-claude/AGENTS.md <<'EOF'
# LearnFlow (Claude Version) - AI-Readable Structure

## Project Overview
LearnFlow is an AI-powered learning platform with four microservices orchestrated by Claude Code agent.

## Directory Structure
- `src/frontend/`: Next.js 14+ with Monaco Editor
- `src/services/agent-orchestrator/`: FastAPI service managing AI agents
- `src/services/curriculum-manager/`: FastAPI service for learning paths
- `src/services/mastery-engine/`: FastAPI service tracking learner progress
- `src/services/code-runner/`: FastAPI service executing code sandboxes
- `src/k8s/`: Kubernetes manifests (Deployments, Services, ConfigMaps, Secrets)
- `.claude/skills/`: Claude CLI Skills compiled from CAPS playbooks
- `docs/`: Docusaurus documentation site

## Technology Stack
- Backend: Python 3.11+ with FastAPI + Dapr
- Frontend: Next.js 14+ with TypeScript, Monaco Editor
- Messaging: Kafka (Dapr pub/sub)
- Storage: PostgreSQL 15+
- Orchestration: Kubernetes 1.27+ with Dapr 1.12+

## Agent-Specific Notes (Claude)
- Use Claude CLI Skills for workflow automation
- Skills located in `.claude/skills/` directory
- Invoke via slash commands: `/sp.plan`, `/sp.tasks`, `/sp.implement`

## State Management
- Dapr state store backed by PostgreSQL
- Pub/sub messaging via Dapr + Kafka
- Service-to-service calls via Dapr service invocation

## Key Files
- `src/services/*/main.py`: FastAPI application entrypoints
- `src/k8s/deployments/*.yaml`: Kubernetes Deployment manifests
- `src/frontend/package.json`: Frontend dependencies
EOF

# Create AGENTS.md for Goose version (mirrors Claude with Goose-specific notes)
cat > learnflow-goose/AGENTS.md <<'EOF'
# LearnFlow (Goose Version) - AI-Readable Structure

## Project Overview
LearnFlow is an AI-powered learning platform with four microservices orchestrated by Goose agent.

## Directory Structure
- `src/frontend/`: Next.js 14+ with Monaco Editor
- `src/services/agent-orchestrator/`: FastAPI service managing AI agents
- `src/services/curriculum-manager/`: FastAPI service for learning paths
- `src/services/mastery-engine/`: FastAPI service tracking learner progress
- `src/services/code-runner/`: FastAPI service executing code sandboxes
- `src/k8s/`: Kubernetes manifests (Deployments, Services, ConfigMaps, Secrets)
- `.goose/recipes/`: Goose Recipes compiled from CAPS playbooks
- `docs/`: Docusaurus documentation site

## Technology Stack
- Backend: Python 3.11+ with FastAPI + Dapr
- Frontend: Next.js 14+ with TypeScript, Monaco Editor
- Messaging: Kafka (Dapr pub/sub)
- Storage: PostgreSQL 15+
- Orchestration: Kubernetes 1.27+ with Dapr 1.12+

## Agent-Specific Notes (Goose)
- Use Goose Recipes for workflow automation
- Recipes located in `.goose/recipes/` directory
- Invoke via recipe commands (Goose-specific syntax)

## State Management
- Dapr state store backed by PostgreSQL
- Pub/sub messaging via Dapr + Kafka
- Service-to-service calls via Dapr service invocation

## Key Files
- `src/services/*/main.py`: FastAPI application entrypoints
- `src/k8s/deployments/*.yaml`: Kubernetes Deployment manifests
- `src/frontend/package.json`: Frontend dependencies
EOF

# Verify AGENTS.md files created
ls -la learnflow-claude/AGENTS.md learnflow-goose/AGENTS.md
```

**Expected Output:**
```
-rw-r--r-- 1 user group 1234 Dec 19 21:00 learnflow-claude/AGENTS.md
-rw-r--r-- 1 user group 1234 Dec 19 21:00 learnflow-goose/AGENTS.md
```

**Success Criteria:**
- [ ] AGENTS.md created in both learnflow-claude/ and learnflow-goose/
- [ ] Files document structure, tech stack, agent-specific notes
- [ ] Both files describe identical business logic
- [ ] Agent-specific differences clearly documented

---

### Step 5: Create Root README

**Objective:** Create project root README documenting dual-agent approach

**Commands:**
```bash
# Create root README.md
cat > README.md <<'EOF'
# LearnFlow - AI-Powered Learning Platform (Hackathon III)

## Overview
LearnFlow is a cloud-native learning platform that uses AI agents to teach Kubernetes mastery through interactive coding exercises. Built following the **CAPS-First Development** paradigm.

## Dual-Agent Architecture
This project demonstrates **agent portability** by implementing LearnFlow in two parallel versions:

- `learnflow-claude/`: Orchestrated by **Claude Code** agent
- `learnflow-goose/`: Orchestrated by **Goose** agent

Both versions implement **identical business logic** from shared **CAPS playbooks**, proving true agent-agnostic development.

## Quick Start
1. **Setup Infrastructure**: Run `minikube-setup` CAPS playbook
2. **Install Dapr**: Run `dapr-k8s-install` CAPS playbook
3. **Deploy Services**: Choose Claude or Goose implementation
4. **Access Frontend**: http://localhost:3000

## Project Structure
```
learnflow/
├── learnflow-claude/       # Claude Code agent version
│   ├── .claude/skills/     # Claude Skills (compiled from CAPS)
│   ├── src/                # Application source code
│   └── AGENTS.md           # AI-readable structure
├── learnflow-goose/        # Goose agent version
│   ├── .goose/recipes/     # Goose Recipes (compiled from CAPS)
│   ├── src/                # Application source code
│   └── AGENTS.md           # AI-readable structure
└── README.md               # This file
```

## Technology Stack
- **Backend**: Python 3.11+ with FastAPI
- **Frontend**: Next.js 14+ with TypeScript, Monaco Editor
- **Infrastructure**: Kubernetes 1.27+, Dapr 1.12+, Helm 3.12+
- **Messaging**: Kafka (via Strimzi Helm chart)
- **Storage**: PostgreSQL 15+
- **AI Agents**: Claude Code, Goose

## Constitution Compliance
This project follows the **SP Constitution** principles:
- ✅ **Principle I**: CAPS-First Development
- ✅ **Principle VIII**: Explicit Feature Parity Between Agent Builds

## Documentation
- See `learnflow-claude/docs/` or `learnflow-goose/docs/` for Docusaurus site
- See `AGENTS.md` in each implementation for AI-readable structure

## License
Hackathon III Project
EOF

# Verify README created
cat README.md | head -20
```

**Expected Output:**
```
# LearnFlow - AI-Powered Learning Platform (Hackathon III)

## Overview
LearnFlow is a cloud-native learning platform that uses AI agents...
```

**Success Criteria:**
- [ ] README.md created in project root
- [ ] Documents dual-agent architecture
- [ ] Quick start instructions provided
- [ ] Constitution compliance noted

---

### Step 6: Initialize Git and Create .gitignore

**Objective:** Configure git repository with proper ignores

**Commands:**
```bash
# Create comprehensive .gitignore
cat > .gitignore <<'EOF'
# Python
__pycache__/
*.py[cod]
*$py.class
*.so
.Python
env/
venv/
ENV/
.venv
pip-log.txt
pip-delete-this-directory.txt

# Node.js / Frontend
node_modules/
npm-debug.log*
yarn-debug.log*
yarn-error.log*
.next/
out/
dist/
build/

# IDE
.vscode/
.idea/
*.swp
*.swo
*~

# OS
.DS_Store
Thumbs.db

# Kubernetes Secrets
**/secrets/*.yaml
!**/secrets/.gitkeep

# Environment Variables
.env
.env.local
.env.*.local

# Logs
*.log
logs/

# Temporary Files
*.tmp
*.temp
EOF

# Stage and commit initial structure
git add .
git commit -m "Claude: initialized LearnFlow dual-agent project structure

- Created learnflow-claude/ and learnflow-goose/ directories
- Added AGENTS.md files for AI observability (Constitution Principle V)
- Established service and K8s manifest structure
- Documented dual-agent architecture in README
- Complies with Constitution Principle VIII (Feature Parity)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>"

# Verify commit
git log --oneline -1
git status
```

**Expected Output:**
```
[main abc1234] Claude: initialized LearnFlow dual-agent project structure
 N files changed, N insertions(+)
On branch main
nothing to commit, working tree clean
```

**Success Criteria:**
- [ ] .gitignore created with comprehensive exclusions
- [ ] Initial commit created with constitution-compliant message
- [ ] Commit follows git pattern: `<agent>: <task> using <playbook>`
- [ ] Working tree clean

---

## Validation

Success criteria (all must pass):

- [ ] **Directory Structure**: `find learnflow-claude learnflow-goose -type d | wc -l` shows 20+ directories
- [ ] **AGENTS.md Present**: `test -f learnflow-claude/AGENTS.md && test -f learnflow-goose/AGENTS.md && echo "PASS"`
- [ ] **README Created**: `test -f README.md && grep -q "Dual-Agent" README.md && echo "PASS"`
- [ ] **Git Initialized**: `git log --oneline | wc -l` shows at least 1 commit
- [ ] **Structure Parity**: Service directories match in both Claude and Goose versions

**Quick Validation Script:**
```bash
# Run all checks
test -d learnflow-claude/.claude && \
  test -d learnflow-goose/.goose && \
  test -f learnflow-claude/AGENTS.md && \
  test -f learnflow-goose/AGENTS.md && \
  test -f README.md && \
  git log --oneline | grep -q "initialized LearnFlow" && \
  echo "✅ All validation checks passed!" || \
  echo "❌ Some validation checks failed"
```

## Troubleshooting

**Problem:** Permission denied creating directories
**Symptoms:** `mkdir: cannot create directory 'learnflow': Permission denied`
**Root Cause:** No write permission in current directory
**Check:**
```bash
# Check directory permissions
ls -ld .
# Should show 'w' permission for user

# Try creating test directory
mkdir test-dir && rmdir test-dir
```
**Fix:**
```bash
# Change to home directory or another writable location
cd ~
mkdir -p projects/hackathon
cd projects/hackathon

# Re-run playbook from Step 1
```

---

**Problem:** Git not initialized properly
**Symptoms:** `fatal: not a git repository`
**Root Cause:** Git init command failed or not in correct directory
**Check:**
```bash
# Check if .git directory exists
ls -la | grep .git
# Should show .git/ directory

# Check git status
git status
```
**Fix:**
```bash
# Re-initialize git
git init
git branch -M main

# Verify
git status
# Should show "On branch main"
```

---

**Problem:** Tree command not found
**Symptoms:** `bash: tree: command not found`
**Root Cause:** Tree utility not installed
**Check:**
```bash
# Check if tree is available
which tree
```
**Fix:**
```bash
# Use find as alternative (already in playbook)
find learnflow-claude -type d

# Or install tree (optional)
# Ubuntu/Debian: sudo apt-get install tree
# macOS: brew install tree
# Windows Git Bash: tree command uses different syntax
```

---

**Problem:** AGENTS.md heredoc fails
**Symptoms:** Heredoc EOF not recognized, multiline string breaks
**Root Cause:** Shell interpretation of heredoc markers
**Check:**
```bash
# Verify EOF marker is on line by itself
cat > test.txt <<'EOF'
content
EOF
```
**Fix:**
```bash
# Ensure no spaces before or after EOF marker
# Use quoted heredoc marker ('EOF') to prevent variable expansion
# If still fails, create files manually:
cat > learnflow-claude/AGENTS.md
# Paste content, press Ctrl+D to save
```

## Notes & References

**Important Considerations:**
- This playbook creates directory structure only (no code yet)
- Both Claude and Goose versions start with identical structure
- AGENTS.md files enable AI agents to understand project layout
- Constitution Principle VIII requires feature parity throughout development

**Performance:**
- Estimated execution time: 15 minutes
- Resource usage: Minimal (directory creation, git operations)
- Network bandwidth: None (no downloads)

**Related Playbooks:**
- `minikube-setup` - Set up local Kubernetes cluster (prerequisite for deployment)
- `dapr-k8s-install` - Install Dapr on cluster (prerequisite for services)
- `fastapi-service-template` - Generate FastAPI service boilerplate (next step)
- `nextjs-frontend-init` - Initialize Next.js frontend (next step)

**External References:**
- [SP Constitution](../../.specify/memory/constitution.md) - Project governance principles
- [CAPS Specification](../../caps-library/docs/sp.abc.md) - Playbook format spec
- [LearnFlow Architecture](../../specs/learnflow/plan.md) - System design (when created)

## Version History

| Version | Date       | Changes                          | Author |
|---------|------------|----------------------------------|--------|
| 1.0.0   | 2025-12-19 | Initial playbook                 | Claude |

---

**Compilation:** This playbook compiles to Claude Skills format using:
```bash
bash caps-library/scripts/caps-to-skills.sh learnflow-project-init --validate
```

**For authoring guidelines, see**: [`caps-library/docs/best-practices.md`](../../caps-library/docs/best-practices.md)
**For validation errors, see**: [`caps-library/docs/validation-guide.md`](../../caps-library/docs/validation-guide.md)
